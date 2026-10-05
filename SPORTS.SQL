-- ============================================================
-- SPORTS CLUB MEMBERSHIP & TOURNAMENT MANAGEMENT SYSTEM
-- Complete Database Script
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: DATABASE INITIALIZATION
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS SportsClubDB;
USE SportsClubDB;

-- ------------------------------------------------------------
-- STEP 2: MASTER / PARENT TABLES
-- ------------------------------------------------------------

-- 1. Membership Plan Table
CREATE TABLE MembershipPlan (
    Plan_ID INT AUTO_INCREMENT PRIMARY KEY,
    Plan_Name VARCHAR(50) NOT NULL UNIQUE,
    Duration INT NOT NULL CHECK (Duration > 0), -- Duration in months
    Fee DECIMAL(10, 2) NOT NULL CHECK (Fee >= 0)
);

-- 2. Member Table
CREATE TABLE Member (
    Member_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Join_Date DATE NOT NULL,
    Status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active'
);

-- 3. Sport Table
CREATE TABLE Sport (
    Sport_ID INT AUTO_INCREMENT PRIMARY KEY,
    Sport_Name VARCHAR(50) NOT NULL UNIQUE,
    Category VARCHAR(50) NOT NULL
);

-- 4. Coach Table
CREATE TABLE Coach (
    Coach_ID INT AUTO_INCREMENT PRIMARY KEY,
    Coach_Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Specialization VARCHAR(50)
);

-- 5. Facility Table
CREATE TABLE Facility (
    Facility_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Location VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Type VARCHAR(50)
);

-- 6. Equipment Table
CREATE TABLE Equipment (
    Equipment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    Available_Quantity INT NOT NULL CHECK (Available_Quantity >= 0)
);

-- ------------------------------------------------------------
-- STEP 3: DEPENDENT / OPERATIONAL TABLES
-- ------------------------------------------------------------

-- 7. Payment Table
CREATE TABLE Payment (
    Payment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Member_ID INT NOT NULL,
    Plan_ID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount >= 0),
    Payment_Date DATE NOT NULL,
    Status ENUM('Completed', 'Pending', 'Failed') DEFAULT 'Completed',
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID) ON DELETE CASCADE,
    FOREIGN KEY (Plan_ID) REFERENCES MembershipPlan(Plan_ID) ON DELETE RESTRICT
);

-- 8. Team Table
CREATE TABLE Team (
    Team_ID INT AUTO_INCREMENT PRIMARY KEY,
    Team_Name VARCHAR(100) NOT NULL UNIQUE,
    Sport_ID INT NOT NULL,
    Coach_ID INT,
    FOREIGN KEY (Sport_ID) REFERENCES Sport(Sport_ID) ON DELETE CASCADE,
    FOREIGN KEY (Coach_ID) REFERENCES Coach(Coach_ID) ON DELETE SET NULL
);

-- 9. Team_Member Table (Resolves M:N Member-Team Relationship)
CREATE TABLE Team_Member (
    Team_ID INT NOT NULL,
    Member_ID INT NOT NULL,
    Join_Date DATE NOT NULL,
    Role VARCHAR(50) DEFAULT 'Player',
    PRIMARY KEY (Team_ID, Member_ID),
    FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID) ON DELETE CASCADE,
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID) ON DELETE CASCADE
);

-- 10. Training Session Table
CREATE TABLE Training_Session (
    Training_ID INT AUTO_INCREMENT PRIMARY KEY,
    Team_ID INT NOT NULL,
    Coach_ID INT NOT NULL,
    Facility_ID INT NOT NULL,
    Date DATE NOT NULL,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,
    CHECK (End_Time > Start_Time),
    FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID) ON DELETE CASCADE,
    FOREIGN KEY (Coach_ID) REFERENCES Coach(Coach_ID) ON DELETE CASCADE,
    FOREIGN KEY (Facility_ID) REFERENCES Facility(Facility_ID) ON DELETE CASCADE
);

-- 11. Tournament Table
CREATE TABLE Tournament (
    Tournament_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Sport_ID INT NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Location VARCHAR(100),
    CHECK (End_Date >= Start_Date),
    FOREIGN KEY (Sport_ID) REFERENCES Sport(Sport_ID) ON DELETE CASCADE
);

-- 12. Participant Table
CREATE TABLE Participant (
    Participant_ID INT AUTO_INCREMENT PRIMARY KEY,
    Tournament_ID INT NOT NULL,
    Team_ID INT NOT NULL,
    FOREIGN KEY (Tournament_ID) REFERENCES Tournament(Tournament_ID) ON DELETE CASCADE,
    FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID) ON DELETE CASCADE,
    CONSTRAINT unique_tournament_team UNIQUE (Tournament_ID, Team_ID)
);

-- 13. Fixture Table
CREATE TABLE Fixture (
    Fixture_ID INT AUTO_INCREMENT PRIMARY KEY,
    Tournament_ID INT NOT NULL,
    Team1_ID INT NOT NULL,
    Team2_ID INT NOT NULL,
    Facility_ID INT NOT NULL,
    Date DATE NOT NULL,
    Start_Time TIME NOT NULL,
    CHECK (Team1_ID <> Team2_ID),
    FOREIGN KEY (Tournament_ID) REFERENCES Tournament(Tournament_ID) ON DELETE CASCADE,
    FOREIGN KEY (Team1_ID) REFERENCES Team(Team_ID) ON DELETE CASCADE,
    FOREIGN KEY (Team2_ID) REFERENCES Team(Team_ID) ON DELETE CASCADE,
    FOREIGN KEY (Facility_ID) REFERENCES Facility(Facility_ID) ON DELETE CASCADE
);

-- 14. Result Table
CREATE TABLE Result (
    Result_ID INT AUTO_INCREMENT PRIMARY KEY,
    Fixture_ID INT UNIQUE NOT NULL,
    Team1_Score INT NOT NULL CHECK (Team1_Score >= 0),
    Team2_Score INT NOT NULL CHECK (Team2_Score >= 0),
    Winner_Team_ID INT,
    FOREIGN KEY (Fixture_ID) REFERENCES Fixture(Fixture_ID) ON DELETE CASCADE,
    FOREIGN KEY (Winner_Team_ID) REFERENCES Team(Team_ID) ON DELETE SET NULL
);

-- 15. Equipment Issue Table
CREATE TABLE Equipment_Issue (
    Issue_ID INT AUTO_INCREMENT PRIMARY KEY,
    Equipment_ID INT NOT NULL,
    Member_ID INT NOT NULL,
    Issue_Date DATE NOT NULL,
    Expected_Return_Date DATE NOT NULL,
    Actual_Return_Date DATE,
    Status ENUM('Issued', 'Returned', 'Overdue') DEFAULT 'Issued',
    CHECK (Expected_Return_Date >= Issue_Date),
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- STEP 4: SAMPLE DATA INSERTION
-- ------------------------------------------------------------

-- Master Data Insertion
INSERT INTO MembershipPlan (Plan_Name, Duration, Fee) VALUES
('Monthly Standard', 1, 50.00),
('Annual Premium', 12, 500.00);

INSERT INTO Member (Name, DOB, Gender, Phone, Email, Join_Date, Status) VALUES
('Alex Smith', '1998-05-15', 'Male', '1234567890', 'alex@example.com', '2025-01-10', 'Active'),
('John Doe', '2000-08-22', 'Male', '0987654321', 'john@example.com', '2025-02-01', 'Active');

INSERT INTO Sport (Sport_Name, Category) VALUES
('Basketball', 'Team Sport'),
('Tennis', 'Individual/Doubles');

INSERT INTO Coach (Coach_Name, Phone, Email, Specialization) VALUES
('Michael Jordan', '1112223333', 'coach.m@example.com', 'Basketball'),
('Serena Williams', '4445556666', 'coach.s@example.com', 'Tennis');

INSERT INTO Facility (Name, Location, Capacity, Type) VALUES
('Main Court', 'Building A', 50, 'Indoor'),
('Outdoor Field', 'Zone B', 100, 'Outdoor');

INSERT INTO Equipment (Name, Category, Quantity, Available_Quantity) VALUES
('Basketball', 'Balls', 20, 18),
('Tennis Racket', 'Rackets', 10, 8);

-- Operations & Linking Data Insertion
INSERT INTO Payment (Member_ID, Plan_ID, Amount, Payment_Date, Status) VALUES
(1, 1, 50.00, '2025-01-10', 'Completed'),
(2, 2, 500.00, '2025-02-01', 'Completed');

INSERT INTO Team (Team_Name, Sport_ID, Coach_ID) VALUES
('Lakers Club', 1, 1),
('Bulls Club', 1, 1);

INSERT INTO Team_Member (Team_ID, Member_ID, Join_Date, Role) VALUES
(1, 1, '2025-01-15', 'Point Guard'),
(2, 2, '2025-02-05', 'Forward');

INSERT INTO Training_Session (Team_ID, Coach_ID, Facility_ID, Date, Start_Time, End_Time) VALUES
(1, 1, 1, '2026-05-10', '08:00:00', '10:00:00');

INSERT INTO Tournament (Name, Sport_ID, Start_Date, End_Date, Location) VALUES
('Summer Basketball Cup', 1, '2026-06-01', '2026-06-10', 'Main Court');

INSERT INTO Participant (Tournament_ID, Team_ID) VALUES
(1, 1),
(1, 2);

INSERT INTO Fixture (Tournament_ID, Team1_ID, Team2_ID, Facility_ID, Date, Start_Time) VALUES
(1, 1, 2, 1, '2026-06-02', '10:00:00');

INSERT INTO Result (Fixture_ID, Team1_Score, Team2_Score, Winner_Team_ID) VALUES
(1, 88, 82, 1);

INSERT INTO Equipment_Issue (Equipment_ID, Member_ID, Issue_Date, Expected_Return_Date, Status) VALUES
(1, 1, '2026-05-01', '2026-05-05', 'Issued');