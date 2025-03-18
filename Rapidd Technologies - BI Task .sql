CREATE TABLE Participants 
(
    ParticipantID Number PRIMARY KEY,    
    FirstName VARCHAR2(50),
    MiddleName VARCHAR2(50),
    LastName VARCHAR2(50),
    DateOfBirth DATE,
    Gender CHAR(1) CHECK (Gender IN ('M','F')),
    Email VARCHAR2(100),
    PersonalPhone VARCHAR2(15)
);

desc Participants;

CREATE TABLE Camps
(
CampID Number Primary Key,
CampTitle Varchar2(100),
StartDate Date,
EndDate Date,
Price Decimal (10,2),
Capacity Int
);

desc Camps;

CREATE TABLE Attendance
(
AttendanceID Number Primary Key,
ParticipantID Int References Participants (ParticipantID),
CampID References Camps (CampID),
VisitYear Int
);

desc Attendance;


CREATE SEQUENCE participant_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Create a table to store camp attendance
CREATE TABLE camp_attendance (
    AttendanceID NUMBER PRIMARY KEY,
    ParticipantID NUMBER,
    CampDate DATE,
    FOREIGN KEY (ParticipantID) REFERENCES participants(ParticipantID)
);

-- Insert 5000 random participants
INSERT INTO participants (ParticipantID, FirstName, MiddleName, LastName, DateOfBirth, Gender, Email, PersonalPhone)
SELECT 
    participant_seq.NEXTVAL,  -- Unique ID
    SUBSTR(DBMS_RANDOM.STRING('X', 8), 1, 8),  -- FirstName (random 8 characters)
    SUBSTR(DBMS_RANDOM.STRING('X', 5), 1, 5),  -- MiddleName (random 5 characters)
    SUBSTR(DBMS_RANDOM.STRING('X', 10), 1, 10), -- LastName (random 10 characters)
    TRUNC(SYSDATE - ( 
        CASE 
            WHEN DBMS_RANDOM.VALUE(0, 1) < 0.18 THEN TRUNC(DBMS_RANDOM.VALUE(7, 13)) -- 18% aged 7-12
            WHEN DBMS_RANDOM.VALUE(0, 1) < 0.45 THEN TRUNC(DBMS_RANDOM.VALUE(13, 15)) -- 27% aged 13-14
            WHEN DBMS_RANDOM.VALUE(0, 1) < 0.65 THEN TRUNC(DBMS_RANDOM.VALUE(15, 18)) -- 20% aged 15-17
            ELSE TRUNC(DBMS_RANDOM.VALUE(18, 20)) -- Remaining 35% aged 18-19
        END * 365)),
    CASE WHEN DBMS_RANDOM.VALUE(0, 1) < 0.65 THEN 'F' ELSE 'M' END,  -- 65% Female, 35% Male
    SUBSTR(DBMS_RANDOM.STRING('X', 8), 1, 8) || '@email.com', -- Random email
    LPAD(TRUNC(DBMS_RANDOM.VALUE(1000000000, 9999999999)), 10, '0') -- Random 10-digit phone number
FROM dual CONNECT BY LEVEL <= 5000;


-- Query to count teenager Lakshmi's camp visits in the last 3 years
Select count(*) as LakshmiVisits from Attendance
Where ParticipantID in (Select ParticipantID from participants where FirstName='Laksmi')
And VisitYear>= Extract(Year from current_date)-3;

SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DateOfBirth) BETWEEN 7 AND 12 THEN '7-12 years'
        WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DateOfBirth) BETWEEN 13 AND 14 THEN '13-14 years'
        WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DateOfBirth) BETWEEN 15 AND 17 THEN '15-17 years'
        ELSE '18-19 years'
    END AS AgeGroup,
    Gender,
    COUNT(*) AS Count
FROM participants
GROUP BY 
    CASE 
        WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DateOfBirth) BETWEEN 7 AND 12 THEN '7-12 years'
        WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DateOfBirth) BETWEEN 13 AND 14 THEN '13-14 years'
        WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DateOfBirth) BETWEEN 15 AND 17 THEN '15-17 years'
        ELSE '18-19 years'
    END,
    Gender
ORDER BY AgeGroup, Gender;

SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM DateOfBirth) BETWEEN 1965 AND 1980 THEN 'Gen X'
        WHEN EXTRACT(YEAR FROM DateOfBirth) BETWEEN 1981 AND 1996 THEN 'Millennials'
        WHEN EXTRACT(YEAR FROM DateOfBirth) BETWEEN 1997 AND 2012 THEN 'Gen Z'
        ELSE 'Gen Alpha'
    END AS Generation,  
    Gender,
    COUNT(*) AS Count
FROM PARTICIPANTS
GROUP BY 
    CASE 
        WHEN EXTRACT(YEAR FROM DateOfBirth) BETWEEN 1965 AND 1980 THEN 'Gen X'
        WHEN EXTRACT(YEAR FROM DateOfBirth) BETWEEN 1981 AND 1996 THEN 'Millennials'
        WHEN EXTRACT(YEAR FROM DateOfBirth) BETWEEN 1997 AND 2012 THEN 'Gen Z'
        ELSE 'Gen Alpha'
    END, Gender
ORDER BY Generation;
