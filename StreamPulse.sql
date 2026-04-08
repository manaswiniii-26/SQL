show databases;
use  Streampulse;
-- 1. Production Houses (Studios like Disney, Marvel)
CREATE TABLE Production_House (
    StudioID INT PRIMARY KEY,
    Studio_Name VARCHAR(100) NOT NULL,
    Headquarters VARCHAR(100),
    Founding_Date DATE
);
-- 2. Cast and Crew (Actors, Directors)
CREATE TABLE Cast_Crew (
    PersonID INT PRIMARY KEY,
    Legal_Name VARCHAR(100) NOT NULL,
    Nationality VARCHAR(50),
    Biography TEXT
);
-- 3. Advertisers (Companies like Nike, Coca-Cola)
CREATE TABLE Advertiser (
    AdCompanyID INT PRIMARY KEY,
    Company_Name VARCHAR(100) NOT NULL,
    Industry VARCHAR(50)
);
-- 4. Awards (Oscars, Emmys)
CREATE TABLE Award (
    AwardID INT PRIMARY KEY,
    Organization VARCHAR(100),
    Award_Year INT,
    Category_Name VARCHAR(100)
);
-- 5. Content Delivery Servers (Technical Infrastructure)
CREATE TABLE CDN_Server (
    ServerID INT PRIMARY KEY,
    Region VARCHAR(50),
    IP_Address VARCHAR(45),
    Storage_Capacity_TB INT
);
	-- 6. Recommendation Engines
	CREATE TABLE Rec_Engine (
		EngineID INT PRIMARY KEY,
		Version VARCHAR(10),
		Model_Type VARCHAR(50)
	);
-- 7. Discount Coupons
CREATE TABLE Discount_Coupon (
    PromoCode VARCHAR(20) PRIMARY KEY,
    Discount_Percent INT CHECK (Discount_Percent BETWEEN 1 AND 100),
    Valid_Until DATE
);
-- 8. User Account (The core "Sun" of the User cluster)
CREATE TABLE User_Account (
    UserID INT PRIMARY KEY,
    First_Name VARCHAR(50),
    M_Initial CHAR(1),
    Last_Name VARCHAR(50),
    Email VARCHAR(100) UNIQUE NOT NULL,
    DOB DATE,
    Street VARCHAR(100),
    City VARCHAR(50),
    Zip VARCHAR(10),
    Country VARCHAR(50)
);
-- 9. User Phone Numbers (Multi-valued attribute from User_Account)
CREATE TABLE User_Phones (
    UserID INT,
    Phone_Number VARCHAR(20),
    PRIMARY KEY (UserID, Phone_Number),
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID) ON DELETE CASCADE
);
-- 10. Premium Subscriber (Sub-type)
CREATE TABLE Premium_Subscriber (
    UserID INT PRIMARY KEY,
    Subscription_Tier VARCHAR(20) CHECK (Subscription_Tier IN ('Basic', 'Standard', 'Family')),
    Billing_Cycle VARCHAR(20),
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID) ON DELETE CASCADE
);
-- 11. Free Viewer (Sub-type)
CREATE TABLE Free_Viewer (
    UserID INT PRIMARY KEY,
    Daily_Ad_Count INT DEFAULT 0,
    Free_Trial_Expiry DATE,
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID) ON DELETE CASCADE
);
-- 12. Profiles (Weak Entity - Depends on User)
CREATE TABLE Profiles (
    UserID INT,
    Profile_Name VARCHAR(50),
    Avatar_URL VARCHAR(255),
    Maturity_Limit VARCHAR(10),
    PRIMARY KEY (UserID, Profile_Name),
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID) ON DELETE CASCADE
);
-- 13. Viewing Devices
CREATE TABLE Viewing_Device (
    DeviceID INT PRIMARY KEY,
    UserID INT,
    Model VARCHAR(50),
    OS_Type VARCHAR(20),
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID) ON DELETE CASCADE
);
-- 14. Support Tickets
CREATE TABLE Support_Ticket (
    TicketID INT PRIMARY KEY,
    UserID INT,
    Subject VARCHAR(255),
    Status VARCHAR(20) DEFAULT 'Open',
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID)
);
-- 15. Financial Transactions
CREATE TABLE Payment_Transaction (
    TransactionID INT PRIMARY KEY,
    UserID INT,
    Amount DECIMAL(10, 2),
    Status VARCHAR(20),
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID)
);
-- 16. Media Content (The core "Sun" of the Content cluster)
CREATE TABLE Media_Content (
    ContentID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Release_Year INT,
    Content_Type VARCHAR(20),
    StudioID INT,
    FOREIGN KEY (StudioID) REFERENCES Production_House(StudioID)
);
-- 17. Episode (Weak Entity - Depends on Media_Content)
CREATE TABLE Episode (
    ContentID INT,
    Episode_Number INT,
    Episode_Title VARCHAR(255),
    Duration_Minutes INT,
    PRIMARY KEY (ContentID, Episode_Number),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID) ON DELETE CASCADE
);
-- 18. Content Relation (Recursive: Prequels/Sequels)
CREATE TABLE Content_Relation (
    Parent_ContentID INT,
    Child_ContentID INT,
    Relation_Type VARCHAR(50),
    PRIMARY KEY (Parent_ContentID, Child_ContentID),
    FOREIGN KEY (Parent_ContentID) REFERENCES Media_Content(ContentID),
    FOREIGN KEY (Child_ContentID) REFERENCES Media_Content(ContentID)
);
-- 19. Performance (M:N between Cast and Media)
CREATE TABLE Performance (
    ContentID INT,
    PersonID INT,
    Character_Role VARCHAR(100),
    Contract_Salary DECIMAL(15, 2),
    PRIMARY KEY (ContentID, PersonID),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID),
    FOREIGN KEY (PersonID) REFERENCES Cast_Crew(PersonID)
);
-- 20. Ad Creative (The actual video file for an ad)
CREATE TABLE Ad_Creative (
    AdID INT PRIMARY KEY,
    AdCompanyID INT,
    Ad_URL VARCHAR(255),
    FOREIGN KEY (AdCompanyID) REFERENCES Advertiser(AdCompanyID)
);
-- TERNARY RELATIONSHIP: Ad_Placement (Advertiser + Ad + Media)
CREATE TABLE Ad_Placement (
    AdID INT,
    ContentID INT,
    AdCompanyID INT,
    Bid_Price DECIMAL(10, 2),
    Timestamp_Marker INT,
    PRIMARY KEY (AdID, ContentID, AdCompanyID),
    FOREIGN KEY (AdID) REFERENCES Ad_Creative(AdID),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID),
    FOREIGN KEY (AdCompanyID) REFERENCES Advertiser(AdCompanyID)
);
-- This table handles the Multi-valued attribute 'Genres'
-- A single Movie/Show (ContentID) can have multiple rows here (Action, Sci-Fi, etc.)


-- 13. NEW: Multi-valued Attribute - Audio Languages
CREATE TABLE Content_Audio_Languages (
    ContentID INT,
    Language_Name VARCHAR(50),
    PRIMARY KEY (ContentID, Language_Name),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID) ON DELETE CASCADE
);
-- 14. NEW: Multi-valued Attribute - Subtitles
CREATE TABLE Content_Subtitles (
    ContentID INT,
    Language_Name VARCHAR(50),
    PRIMARY KEY (ContentID, Language_Name),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID) ON DELETE CASCADE
);
-- 20. Social: User Reviews
CREATE TABLE User_Review (
    ReviewID INT PRIMARY KEY,
    UserID INT,
    ContentID INT,
    Stars INT,
    FOREIGN KEY (UserID) REFERENCES User_Account(UserID),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID)
);
-- Requirement: Streaming Platforms 
CREATE TABLE Streaming_Platforms (
    PlatformID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Base_Monthly_Price DECIMAL(10, 2),
    Resolution_Supported VARCHAR(20) -- e.g., '4K', '1080p' 
);
CREATE TABLE Content_Provider_Bridge (
    ContentID INT,
    PlatformID INT,
    Is_Exclusive BOOLEAN DEFAULT FALSE, -- Tracking Exclusivity 
    PRIMARY KEY (ContentID, PlatformID),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID) ON DELETE CASCADE,
    FOREIGN KEY (PlatformID) REFERENCES Streaming_Platforms(PlatformID) ON DELETE CASCADE -- Requirement: ON DELETE CASCADE 
);

CREATE TABLE Genre_Lookup (
    GenreID INT PRIMARY KEY,
    Genre_Name VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE Content_Genre_Map (
    ContentID INT,
    GenreID INT,
    PRIMARY KEY (ContentID, GenreID),
    FOREIGN KEY (ContentID) REFERENCES Media_Content(ContentID) ON DELETE CASCADE,
    FOREIGN KEY (GenreID) REFERENCES Genre_Lookup(GenreID) ON DELETE CASCADE
);
SELECT m.Title FROM Media_Content m
JOIN Content_Provider_Bridge b ON m.ContentID = b.ContentID
JOIN Streaming_Platforms s ON b.PlatformID = s.PlatformID
WHERE s.Resolution_Supported = '4K' AND s.Name IN ('Netflix', 'Prime');
SELECT COUNT(*) FROM Media_Content m
JOIN Content_Provider_Bridge b ON m.ContentID = b.ContentID
JOIN Streaming_Platforms s ON b.PlatformID = s.PlatformID
JOIN Content_Genre_Map gm ON m.ContentID = gm.ContentID
JOIN Genre_Lookup g ON gm.GenreID = g.GenreID
WHERE g.Genre_Name = 'Sci-Fi' AND s.Name = 'Disney+' AND b.Is_Exclusive = TRUE;
-- Phase 2: Data Population (DML) 
-- Populating 5 major Production Houses/Platforms 


INSERT INTO Rec_Engine (EngineID, Version, Model_Type) VALUES 
(1, 'v1.0', 'Basic Collaborative Filtering'),
(2, 'v1.1', 'Advanced Collaborative Filtering'),
(3, 'v1.2', 'Simple Content-Based Filtering'),
(4, 'v1.3', 'Advanced Content-Based Filtering'),
(5, 'v1.4', 'Demographic-Based Recommender'),
(6, 'v2.0', 'Hybrid Filtering (Alpha)'),
(7, 'v2.1', 'Hybrid Filtering (Beta)'),
(8, 'v2.2', 'Matrix Factorization (SVD)'),
(9, 'v2.3', 'Matrix Factorization (ALS)'),
(10, 'v2.4', 'K-Nearest Neighbors (KNN)'),
(11, 'v3.0', 'Association Rule Mining'),
(12, 'v3.1', 'Apriori Algorithm Integration'),
(13, 'v3.2', 'FP-Growth Algorithm'),
(14, 'v3.3', 'Knowledge-Based Filtering'),
(15, 'v3.4', 'Constraint-Based Recommender'),
(16, 'v4.0', 'Deep Learning - MLP'),
(17, 'v4.1', 'Deep Learning - CNN for Metadata'),
(18, 'v4.2', 'Deep Learning - RNN for Sequences'),
(19, 'v4.3', 'Neural Collaborative Filtering'),
(20, 'v4.4', 'Wide and Deep Learning Model'),
(21, 'v5.0', 'Reinforcement Learning - Bandit'),
(22, 'v5.1', 'Reinforcement Learning - Q-Learning'),
(23, 'v5.2', 'Deep Q-Networks (DQN)'),
(24, 'v5.3', 'Policy Gradient Methods'),
(25, 'v5.4', 'Actor-Critic Framework'),
(26, 'v6.0', 'Gradient Boosted Trees (XGBoost)'),
(27, 'v6.1', 'LightGBM Ranking Model'),
(28, 'v6.2', 'CatBoost Categorical Model'),
(29, 'v6.3', 'Ensemble Stacking Model'),
(30, 'v6.4', 'Bagging Meta-Estimator'),
(31, 'v7.0', 'Graph Neural Networks (GCN)'),
(32, 'v7.1', 'GraphSage Sampling'),
(33, 'v7.2', 'Knowledge Graph Embeddings'),
(34, 'v7.3', 'Social Network Awareness Engine'),
(35, 'v7.4', 'Community Detection Logic'),
(36, 'v8.0', 'Context-Aware (Time/Location)'),
(37, 'v8.1', 'Device-Specific Optimization'),
(38, 'v8.2', 'Mood-Based Analytics Engine'),
(39, 'v8.3', 'Multi-Criteria Decision Making'),
(40, 'v8.4', 'Pareto-Optimal Recommender'),
(41, 'v9.0', 'Transformer-Based Attention'),
(42, 'v9.1', 'BERT4Rec Implementation'),
(43, 'v9.2', 'GPT-Enhanced Metadata Processing'),
(44, 'v9.3', 'Cross-Domain Transfer Learning'),
(45, 'v9.4', 'Zero-Shot Recommendation'),
(46, 'v10.0', 'Explainable AI (LIME)'),
(47, 'v10.1', 'Explainable AI (SHAP)'),
(48, 'v10.2', 'Federated Learning (Privacy)'),
(49, 'v10.3', 'Self-Supervised Learning'),
(50, 'v10.4', 'Hyper-Personalized Meta-Engine');
INSERT INTO Discount_Coupon (PromoCode, Discount_Percent, Valid_Until) VALUES 
('WELCOME10', 10, '2026-12-31'),
('STREAM20', 20, '2026-06-30'),
('BINGE50', 50, '2026-05-15'),
('PROMO25', 25, '2026-08-20'),
('SAVE15', 15, '2026-09-10'),
('FESTIVE30', 30, '2026-12-25'),
('NEWUSER40', 40, '2026-07-01'),
('CHILL05', 5, '2026-11-30'),
('MAXSAVE60', 60, '2026-04-30'),
('SPRING10', 10, '2026-05-31'),
('SUMMER25', 25, '2026-08-31'),
('AUTUMN15', 15, '2026-11-30'),
('WINTER20', 20, '2027-02-28'),
('HALFOFF', 50, '2026-10-15'),
('QUARTER25', 25, '2026-06-15'),
('LUCKY77', 77, '2026-07-07'),
('TRIAL100', 100, '2026-04-15'),
('LOYALTY12', 12, '2026-12-31'),
('STUDENT35', 35, '2026-09-30'),
('FAMILY45', 45, '2026-08-15'),
('WEEKEND10', 10, '2026-05-10'),
('NIGHTOWL20', 20, '2026-07-20'),
('EARLYBIRD30', 30, '2026-04-20'),
('FLASHSALE55', 55, '2026-04-05'),
('RENEWAL15', 15, '2026-10-01'),
('ANNIVERSARY50', 50, '2026-11-11'),
('HOLIDAY35', 35, '2026-12-20'),
('BIRTHDAY25', 25, '2026-12-31'),
('COUPON01', 1, '2026-12-31'),
('BIGDEAL70', 70, '2026-05-05'),
('SMARTSAVE18', 18, '2026-09-15'),
('EXTRASAVE22', 22, '2026-10-22'),
('PREMIUM10', 10, '2026-12-01'),
('GOLDEN30', 30, '2026-06-25'),
('SILVER15', 15, '2026-06-25'),
('BRONZE05', 5, '2026-06-25'),
('CYBER25', 25, '2026-11-30'),
('BLACKFRIDAY40', 40, '2026-11-27'),
('EASTER20', 20, '2026-04-12'),
('VALENTINE14', 14, '2026-02-14'),
('FREEMONTH', 100, '2026-08-01'),
('PULSE10', 10, '2026-07-15'),
('VIBE15', 15, '2026-08-15'),
('JUMP20', 20, '2026-09-15'),
('SOP25', 25, '2026-10-15'),
('TECH30', 30, '2026-11-15'),
('CORE35', 35, '2026-12-15'),
('META40', 40, '2026-05-20'),
('BRIDGE45', 45, '2026-06-20'),
('SCHEMA50', 50, '2026-07-20');
INSERT INTO User_Account (UserID, First_Name, M_Initial, Last_Name, Email, DOB, Street, City, Zip, Country) VALUES 
(1, 'Aarav', 'V', 'Sharma', 'aarav.v.sharma@email.com', '1992-03-12', '123 MG Road', 'Mumbai', '400001', 'India'),
(2, 'Emma', 'L', 'Smith', 'emma.l.smith@email.com', '1985-07-22', '456 Oak Ave', 'New York', '10001', 'USA'),
(3, 'Liam', 'J', 'Brown', 'liam.j.brown@email.com', '1998-11-05', '789 Pine St', 'London', 'E1 6AN', 'UK'),
(4, 'Sofia', 'M', 'Garcia', 'sofia.m.garcia@email.com', '2001-01-30', '321 Calle Mayor', 'Madrid', '28001', 'Spain'),
(5, 'Yuki', 'K', 'Tanaka', 'yuki.k.tanaka@email.com', '1990-09-15', '10-1 Ginza', 'Tokyo', '104-0061', 'Japan'),
(6, 'Hans', 'B', 'Müller', 'hans.b.muller@email.com', '1982-12-01', '55 Berlin Str', 'Berlin', '10115', 'Germany'),
(7, 'Chloe', 'R', 'Wilson', 'chloe.r.wilson@email.com', '1995-04-18', '88 Sydney Rd', 'Sydney', '2000', 'Australia'),
(8, 'Ivan', 'S', 'Petrov', 'ivan.s.petrov@email.com', '1988-06-25', '12 Nevsky Ave', 'St. Petersburg', '191186', 'Russia'),
(9, 'Maria', 'L', 'Silva', 'maria.l.silva@email.com', '1993-08-08', '77 Avenida Paulista', 'Sao Paulo', '01311-923', 'Brazil'),
(10, 'Chen', 'W', 'Wei', 'chen.w.wei@email.com', '1996-02-14', '99 Nanjing Rd', 'Shanghai', '200001', 'China'),
(11, 'Sarah', 'K', 'Connor', 'sarah.k.connor@email.com', '1980-05-12', '1 Sky Net Ln', 'Los Angeles', '90001', 'USA'),
(12, 'Arjun', 'P', 'Kapoor', 'arjun.p.kapoor@email.com', '1994-10-10', '44 Marine Drive', 'Mumbai', '400020', 'India'),
(13, 'Fatima', 'A', 'Zahra', 'fatima.a.zahra@email.com', '1999-03-03', '22 Palm Jumeirah', 'Dubai', '00000', 'UAE'),
(14, 'Luca', 'D', 'Rossi', 'luca.d.rossi@email.com', '1987-11-11', '33 Via Roma', 'Rome', '00118', 'Italy'),
(15, 'Amélie', 'P', 'Poulain', 'amelie.p.poulain@email.com', '1991-05-05', '15 Rue Lepic', 'Paris', '75018', 'France'),
(16, 'Oliver', 'G', 'Twist', 'oliver.g.twist@email.com', '2003-07-07', '10 Dickens Way', 'London', 'WC1N 2LX', 'UK'),
(17, 'Ananya', 'R', 'Iyer', 'ananya.r.iyer@email.com', '1997-09-09', '66 Brigade Rd', 'Bangalore', '560001', 'India'),
(18, 'Noah', 'S', 'Miller', 'noah.s.miller@email.com', '1989-01-20', '101 Maple Ave', 'Toronto', 'M5V 2L7', 'Canada'),
(19, 'Isabella', 'F', 'Martínez', 'isabella.f.martinez@email.com', '1992-04-04', '50 Reforma Ave', 'Mexico City', '06600', 'Mexico'),
(20, 'Kim', 'D', 'Min-ho', 'kim.d.minho@email.com', '1986-10-25', '77 Gangnam-daero', 'Seoul', '06232', 'South Korea'),
(21, 'Lars', 'H', 'Nielsen', 'lars.h.nielsen@email.com', '1983-02-28', '12 Nyhavn', 'Copenhagen', '1051', 'Denmark'),
(22, 'Priya', 'M', 'Desai', 'priya.m.desai@email.com', '1995-12-12', '88 Park St', 'Kolkata', '700016', 'India'),
(23, 'Sven', 'G', 'Eriksson', 'sven.g.eriksson@email.com', '1981-08-15', '20 Vasagatan', 'Stockholm', '111 20', 'Sweden'),
(24, 'Elena', 'V', 'Popova', 'elena.v.popova@email.com', '1990-03-20', '5 Arbat St', 'Moscow', '119019', 'Russia'),
(25, 'Diego', 'A', 'Torres', 'diego.a.torres@email.com', '1994-06-30', '100 Florida St', 'Buenos Aires', 'C1005', 'Argentina'),
(26, 'Sita', 'K', 'Ramani', 'sita.k.ramani@email.com', '1988-11-11', '45 Mount Rd', 'Chennai', '600002', 'India'),
(27, 'Jean', 'L', 'Dupont', 'jean.l.dupont@email.com', '1985-05-15', '10 Rue de Rivoli', 'Paris', '75001', 'France'),
(28, 'Zeynep', 'E', 'Yilmaz', 'zeynep.e.yilmaz@email.com', '1997-07-07', '30 Istiklal Ave', 'Istanbul', '34433', 'Turkey'),
(29, 'Ali', 'H', 'Khan', 'ali.h.khan@email.com', '2000-09-10', '15 Shahrah-e-Faisal', 'Karachi', '75500', 'Pakistan'),
(30, 'Olivia', 'W', 'Johnson', 'olivia.w.johnson@email.com', '1993-01-25', '200 Main St', 'Chicago', '60601', 'USA'),
(31, 'Rahul', 'S', 'Mehta', 'rahul.s.mehta@email.com', '1991-04-12', '12 CP Circle', 'New Delhi', '110001', 'India'),
(32, 'Anna', 'M', 'Schmidt', 'anna.m.schmidt@email.com', '1989-10-30', '100 Marienplatz', 'Munich', '80331', 'Germany'),
(33, 'Jack', 'D', 'Sparrow', 'jack.d.sparrow@email.com', '1984-06-09', '1 Tortuga Bay', 'Port Royal', '00001', 'Jamaica'),
(34, 'Nina', 'I', 'Ivanova', 'nina.i.ivanova@email.com', '1996-03-15', '50 Tverskaya St', 'Moscow', '125009', 'Russia'),
(35, 'Leo', 'M', 'Messi', 'leo.m.messi@email.com', '1987-06-24', '10 Rosario Way', 'Barcelona', '08001', 'Spain'),
(36, 'Ishani', 'B', 'Bose', 'ishani.b.bose@email.com', '1998-02-20', '33 Salt Lake', 'Kolkata', '700091', 'India'),
(37, 'Bruce', 'W', 'Wayne', 'bruce.w.wayne@email.com', '1980-02-19', '1 Wayne Manor', 'Gotham', '53540', 'USA'),
(38, 'Diana', 'P', 'Prince', 'diana.p.prince@email.com', '1985-03-22', '10 Themyscira Blvd', 'Gateway City', '20001', 'USA'),
(39, 'Clark', 'J', 'Kent', 'clark.j.kent@email.com', '1988-06-18', '344 Clinton St', 'Metropolis', '62960', 'USA'),
(40, 'Vihaan', 'A', 'Reddy', 'vihaan.a.reddy@email.com', '1994-08-15', '10 Banjara Hills', 'Hyderabad', '500034', 'India'),
(41, 'Sophie', 'T', 'Turner', 'sophie.t.turner@email.com', '1996-02-21', '5 Winterfell Rd', 'Northampton', 'NN1 1AA', 'UK'),
(42, 'Rohan', 'V', 'Verma', 'rohan.v.verma@email.com', '1992-12-25', '77 Gomti Nagar', 'Lucknow', '226010', 'India'),
(43, 'Keanu', 'C', 'Reeves', 'keanu.c.reeves@email.com', '1984-09-02', '10 Matrix Way', 'Beirut', '1107', 'Lebanon'),
(44, 'Sia', 'A', 'Furler', 'sia.a.furler@email.com', '1975-12-18', '1 Adelaide St', 'Adelaide', '5000', 'Australia'),
(45, 'Dev', 'K', 'Patel', 'dev.k.patel@email.com', '1990-04-23', '20 Harrow Rd', 'London', 'HA1 1BB', 'UK'),
(46, 'Kyrie', 'A', 'Irving', 'kyrie.a.irving@email.com', '1992-03-23', '11 Melbourne Dr', 'Melbourne', '3000', 'Australia'),
(47, 'Meera', 'N', 'Nair', 'meera.n.nair@email.com', '1983-05-30', '100 Kovalam Rd', 'Trivandrum', '695001', 'India'),
(48, 'Anders', 'L', 'Lindberg', 'anders.l.lindberg@email.com', '1981-11-20', '5 Fjord Way', 'Oslo', '0101', 'Norway'),
(49, 'Zara', 'M', 'Hassan', 'zara.m.hassan@email.com', '1999-01-01', '25 Nile St', 'Cairo', '11511', 'Egypt'),
(50, 'Vikram', 'D', 'Seth', 'vikram.d.seth@email.com', '1982-06-20', '15 Lodi Rd', 'New Delhi', '110003', 'India');

INSERT INTO User_Phones (UserID, Phone_Number) VALUES 
(1, '+91-98765-43210'), (1, '+91-22-2401-0000'),
(2, '+1-212-555-0198'), (2, '+1-212-555-0199'),
(3, '+44-20-7946-0123'), (4, '+34-913-633-100'),
(5, '+81-3-3567-0111'), (5, '+81-90-1234-5678'),
(6, '+49-30-23125-0'), (7, '+61-2-9211-1111'),
(8, '+7-812-326-18-20'), (9, '+55-11-3133-3333'),
(10, '+86-21-6321-0000'), (11, '+1-213-555-0101'),
(12, '+91-22-2202-0011'), (12, '+91-98200-12345'),
(13, '+971-4-366-8888'), (14, '+39-06-6710-1'),
(15, '+33-1-42-55-79-76'), (16, '+44-20-7405-2107'),
(17, '+91-80-2221-0000'), (18, '+1-416-555-0144'),
(19, '+52-55-5140-6000'), (20, '+82-2-3450-2114'),
(21, '+45-33-12-12-12'), (22, '+91-33-2287-0000'),
(23, '+46-8-506-230-00'), (24, '+7-495-933-33-33'),
(25, '+54-11-4348-1900'), (26, '+91-44-2852-0000'),
(27, '+33-1-44-77-70-70'), (28, '+90-212-251-58-60'),
(29, '+92-21-3568-1234'), (30, '+1-312-555-0155'),
(31, '+91-11-2331-0000'), (32, '+49-89-233-00'),
(33, '+1-876-555-0101'), (34, '+7-495-629-20-00'),
(35, '+34-93-402-70-00'), (36, '+91-33-2358-0000'),
(37, '+1-535-555-0100'), (38, '+1-202-555-0121'),
(39, '+1-629-555-0134'), (40, '+91-40-2335-0000'),
(41, '+44-1604-555123'), (42, '+91-522-230-0000'),
(43, '+961-1-350-000'), (44, '+61-8-8201-1111'),
(45, '+44-20-8864-0000'), (46, '+61-3-9658-9658');
INSERT INTO Premium_Subscriber (UserID, Subscription_Tier, Billing_Cycle) VALUES 
(1, 'Family', 'Monthly'),
(2, 'Standard', 'Yearly'),
(3, 'Basic', 'Monthly'),
(4, 'Family', 'Yearly'),
(5, 'Standard', 'Monthly'),
(6, 'Basic', 'Monthly'),
(7, 'Family', 'Yearly'),
(8, 'Standard', 'Monthly'),
(9, 'Basic', 'Yearly'),
(10, 'Family', 'Monthly'),
(11, 'Standard', 'Yearly'),
(12, 'Basic', 'Monthly'),
(13, 'Family', 'Monthly'),
(14, 'Standard', 'Yearly'),
(15, 'Basic', 'Monthly'),
(16, 'Family', 'Yearly'),
(17, 'Standard', 'Monthly'),
(18, 'Basic', 'Yearly'),
(19, 'Family', 'Monthly'),
(20, 'Standard', 'Yearly'),
(21, 'Basic', 'Monthly'),
(22, 'Family', 'Yearly'),
(23, 'Standard', 'Monthly'),
(24, 'Basic', 'Yearly'),
(25, 'Family', 'Monthly');

INSERT INTO Free_Viewer (UserID, Daily_Ad_Count, Free_Trial_Expiry) VALUES 
(26, 5, '2026-05-15'),
(27, 2, '2026-06-01'),
(28, 8, '2026-04-20'),
(29, 0, '2026-07-10'),
(30, 4, '2026-05-25'),
(31, 10, '2026-04-15'),
(32, 1, '2026-08-12'),
(33, 12, '2026-05-05'),
(34, 3, '2026-06-30'),
(35, 7, '2026-04-30'),
(36, 0, '2026-09-01'),
(37, 15, '2026-05-20'),
(38, 2, '2026-07-15'),
(39, 6, '2026-08-20'),
(40, 9, '2026-04-10'),
(41, 1, '2026-10-05'),
(42, 5, '2026-11-12'),
(43, 8, '2026-05-01'),
(44, 0, '2026-12-25'),
(45, 11, '2026-06-15'),
(46, 4, '2026-07-07'),
(47, 2, '2026-08-31'),
(48, 6, '2026-09-15'),
(49, 10, '2026-04-25'),
(50, 3, '2026-10-10');
INSERT INTO Profiles (UserID, Profile_Name, Avatar_URL, Maturity_Limit) VALUES 
(1, 'Aarav_Main', 'avatar_01.png', 'Adult'), (1, 'Aarav_Kids', 'kids_icon.png', 'Kids'),
(2, 'Emma_Work', 'pro_office.png', 'Adult'), (2, 'Emma_Home', 'home_chill.png', 'Adult'),
(3, 'Liam_UK', 'london_eye.png', 'Adult'), (3, 'Liam_Guest', 'guest_icon.png', 'Teen'),
(4, 'Sofia_Main', 'spain_flag.png', 'Adult'),
(5, 'Yuki_Tokyo', 'ninja_art.png', 'Adult'), (5, 'Yuki_Family', 'fam_icon.png', 'Kids'),
(6, 'Hans_B', 'berlin_wall.png', 'Adult'),
(7, 'Chloe_W', 'kangaroo.png', 'Adult'), (7, 'Chloe_Junior', 'joey.png', 'Kids'),
(8, 'Ivan_P', 'winter_cap.png', 'Adult'),
(9, 'Maria_L', 'samba_mask.png', 'Adult'), (9, 'Maria_Private', 'lock_icon.png', 'Adult'),
(10, 'Chen_Wei', 'dragon.png', 'Adult'),
(11, 'Sarah_C', 'tech_icon.png', 'Adult'), (11, 'Sarah_Alt', 'sunset.png', 'Adult'),
(12, 'Arjun_K', 'bollywood.png', 'Adult'), (12, 'Arjun_Brother', 'cricket.png', 'Teen'),
(13, 'Fatima_Z', 'desert_sun.png', 'Adult'),
(14, 'Luca_R', 'colosseum.png', 'Adult'), (14, 'Luca_Kids', 'pizza_slice.png', 'Kids'),
(15, 'Amélie_P', 'french_cat.png', 'Adult'),
(16, 'Oliver_T', 'victorian.png', 'Teen'),
(17, 'Ananya_I', 'lotus.png', 'Adult'),
(18, 'Noah_M', 'maple_leaf.png', 'Adult'), (18, 'Noah_Partner', 'heart.png', 'Adult'),
(19, 'Isabella_F', 'taco_emoji.png', 'Adult'),
(20, 'Kim_Min', 'kpop_star.png', 'Adult'), (20, 'Kim_Sister', 'drama_fan.png', 'Teen'),
(21, 'Lars_N', 'viking_ship.png', 'Adult'),
(22, 'Priya_D', 'saree_icon.png', 'Adult'), (22, 'Priya_Study', 'book_icon.png', 'Adult'),
(23, 'Sven_E', 'ikea_blue.png', 'Adult'),
(24, 'Elena_P', 'matryoshka.png', 'Adult'), (24, 'Elena_Mom', 'tea_cup.png', 'Adult'),
(25, 'Diego_T', 'football.png', 'Adult'),
(26, 'Sita_R', 'temple_art.png', 'Adult'),
(27, 'Jean_D', 'eiffel_tower.png', 'Adult'), (27, 'Jean_Junior', 'soccer_ball.png', 'Kids'),
(28, 'Zeynep_Y', 'evil_eye.png', 'Adult'),
(29, 'Ali_K', 'green_star.png', 'Adult'),
(30, 'Olivia_J', 'windy_city.png', 'Adult'), (30, 'Olivia_Kids', 'cartoon_dog.png', 'Kids'),
(31, 'Rahul_M', 'india_gate.png', 'Adult'),
(32, 'Anna_S', 'pretzel.png', 'Adult'),
(33, 'Jack_S', 'pirate_flag.png', 'Adult'), (33, 'Jack_Crew', 'anchor.png', 'Teen'),
(34, 'Nina_I', 'ballet.png', 'Adult'),
(35, 'Leo_M', 'goal_post.png', 'Adult');
INSERT INTO Viewing_Device (DeviceID, UserID, Model, OS_Type) VALUES 
(1, 1, 'iPhone 15 Pro', 'iOS'), (2, 1, 'Samsung QLED 4K', 'Tizen'),
(3, 2, 'iPad Air', 'iPadOS'), (4, 2, 'Apple TV 4K', 'tvOS'),
(5, 3, 'Google Pixel 8', 'Android'), (6, 3, 'Sony Bravia', 'Android TV'),
(7, 4, 'MacBook Pro M3', 'macOS'), (8, 5, 'Sony PlayStation 5', 'PS5 OS'),
(9, 6, 'Xbox Series X', 'Xbox OS'), (10, 7, 'Amazon Fire Stick', 'Fire OS'),
(11, 8, 'Xiaomi Mi 11', 'Android'), (12, 9, 'LG OLED C3', 'webOS'),
(13, 10, 'Windows Desktop', 'Windows 11'), (14, 11, 'iPhone 14', 'iOS'),
(15, 12, 'Samsung Galaxy S23', 'Android'), (16, 13, 'Roku Ultra', 'Roku OS'),
(17, 14, 'Nvidia Shield', 'Android TV'), (18, 15, 'Surface Pro 9', 'Windows 11'),
(19, 16, 'Nintendo Switch', 'Horizon OS'), (20, 17, 'OnePlus 11', 'OxygenOS'),
(21, 18, 'Chromecast with TV', 'Google TV'), (22, 19, 'iPhone 13 Mini', 'iOS'),
(23, 20, 'Samsung Tab S9', 'Android'), (24, 21, 'TCL 6-Series', 'Roku OS'),
(25, 22, 'Asus ROG Ally', 'Windows 11'), (26, 23, 'Vizio M-Series', 'SmartCast'),
(27, 24, 'Motorola Edge', 'Android'), (28, 25, 'Panasonic VIERA', 'My Home Screen'),
(29, 26, 'iPhone SE 2022', 'iOS'), (30, 27, 'Huawei P60', 'HarmonyOS'),
(31, 28, 'Dell XPS 15', 'Windows 11'), (32, 29, 'Oppo Find X6', 'ColorOS'),
(33, 30, 'Hisense U8H', 'Google TV'), (34, 31, 'Realme GT', 'Android'),
(35, 32, 'Sony Xperia 1 V', 'Android'), (36, 33, 'iPhone 12', 'iOS'),
(37, 34, 'iPad Pro 12.9', 'iPadOS'), (38, 35, 'Nokia G42', 'Android'),
(39, 36, 'Lenovo Legion Go', 'Windows 11'), (40, 37, 'Samsung Galaxy Flip 5', 'Android'),
(41, 38, 'Apple TV HD', 'tvOS'), (42, 39, 'Kindle Fire HD', 'Fire OS'),
(43, 40, 'Skyworth TV', 'Android TV'), (44, 41, 'Nothing Phone 2', 'Nothing OS'),
(45, 42, 'Vivo X90', 'Funtouch OS'), (46, 43, 'Infinix Zero', 'XOS'),
(47, 44, 'Techno Camon', 'HiOS'), (48, 45, 'Mac Mini M2', 'macOS'),
(49, 46, 'Steam Deck', 'SteamOS'), (50, 47, 'Sharp Aquos', 'Android TV');
INSERT INTO Support_Ticket (TicketID, UserID, Subject, Status) VALUES 
(1, 1, 'Cannot login to my account', 'Closed'),
(2, 2, 'Subscription payment failed', 'Resolved'),
(3, 3, '4K streaming not working on TV', 'Open'),
(4, 4, 'How to change my email address?', 'Closed'),
(5, 5, 'Buffering issues on mobile app', 'In Progress'),
(6, 6, 'Requesting refund for double charge', 'Pending'),
(7, 7, 'Subtitles out of sync', 'Closed'),
(8, 8, 'App crashes on launch', 'Open'),
(9, 9, 'Forgot my password', 'Resolved'),
(10, 10, 'Device limit reached error', 'Closed'),
(11, 11, 'Missing episode in Series X', 'Open'),
(12, 12, 'Billing cycle clarification', 'Closed'),
(13, 13, 'Audio language not changing', 'In Progress'),
(14, 14, 'Delete my profile request', 'Closed'),
(15, 15, 'Video quality is very low', 'Open'),
(16, 16, 'Gift card code not working', 'Pending'),
(17, 17, 'Screen flickering during playback', 'Open'),
(18, 18, 'Update credit card details', 'Closed'),
(19, 19, 'Content not available in my region', 'Resolved'),
(20, 20, 'Parental controls setup help', 'Closed'),
(21, 21, 'Unable to download for offline use', 'Open'),
(22, 22, 'Black screen on start', 'In Progress'),
(23, 23, 'Duplicate account found', 'Closed'),
(24, 24, 'Unauthorized login alert', 'Pending'),
(25, 25, 'Profile avatar not updating', 'Closed'),
(26, 26, 'Ad-free experience not working', 'Open'),
(27, 27, 'Trial period inquiry', 'Resolved'),
(28, 28, 'Smart TV app setup', 'Closed'),
(29, 29, 'Poor connection error 404', 'Open'),
(30, 30, 'Promocode SAVE20 failed', 'In Progress'),
(31, 31, 'Account hacked recovery', 'Pending'),
(32, 32, 'Search bar not returning results', 'Closed'),
(33, 33, 'Audio sync issue on Chrome', 'Open'),
(34, 34, 'Cancel my subscription', 'Closed'),
(35, 35, 'Change billing date', 'Resolved'),
(36, 36, 'Family plan member limit', 'Closed'),
(37, 37, 'HDR10+ support inquiry', 'In Progress'),
(38, 38, 'Application very slow', 'Open'),
(39, 39, 'Login loop on PlayStation', 'Pending'),
(40, 40, 'Incorrect currency displayed', 'Closed'),
(41, 41, 'Episode 5 audio missing', 'Open'),
(42, 42, 'Chromecast icon not showing', 'In Progress'),
(43, 43, 'Feedback on new UI', 'Closed'),
(44, 44, 'Student discount verification', 'Open'),
(45, 45, 'VPN detection error', 'Pending'),
(46, 46, 'Wrong billing address', 'Closed'),
(47, 47, 'Subtitle font size request', 'Resolved'),
(48, 48, 'FireStick app frozen', 'Open'),
(49, 49, 'Password reset link expired', 'In Progress'),
(50, 50, 'Annual plan upgrade', 'Closed');
INSERT INTO Payment_Transaction (TransactionID, UserID, Amount, Status) VALUES 
(1, 1, 15.99, 'Success'), (2, 2, 120.00, 'Success'), (3, 3, 9.99, 'Success'),
(4, 4, 149.99, 'Pending'), (5, 5, 12.99, 'Success'), (6, 6, 9.99, 'Failed'),
(7, 7, 130.00, 'Success'), (8, 8, 12.99, 'Success'), (9, 9, 89.99, 'Success'),
(10, 10, 15.99, 'Success'), (11, 11, 110.00, 'Success'), (12, 12, 9.99, 'Success'),
(13, 13, 15.99, 'Success'), (14, 14, 120.00, 'Failed'), (15, 15, 9.99, 'Success'),
(16, 16, 149.99, 'Success'), (17, 17, 12.99, 'Success'), (18, 18, 95.00, 'Success'),
(19, 19, 15.99, 'Success'), (20, 20, 120.00, 'Pending'), (21, 21, 9.99, 'Success'),
(22, 22, 135.00, 'Success'), (23, 23, 12.99, 'Success'), (24, 24, 99.99, 'Success'),
(25, 25, 15.99, 'Success'), (26, 26, 0.00, 'Success'), (27, 27, 0.00, 'Success'),
(28, 28, 0.00, 'Success'), (29, 29, 5.99, 'Failed'), (30, 30, 7.99, 'Success'),
(31, 31, 15.99, 'Success'), (32, 32, 12.99, 'Success'), (33, 33, 15.99, 'Success'),
(34, 34, 9.99, 'Pending'), (35, 35, 12.99, 'Success'), (36, 36, 15.99, 'Success'),
(37, 37, 120.00, 'Success'), (38, 38, 12.99, 'Success'), (39, 39, 15.99, 'Failed'),
(40, 40, 9.99, 'Success'), (41, 41, 14.99, 'Success'), (42, 42, 12.99, 'Success'),
(43, 43, 15.99, 'Success'), (44, 44, 7.99, 'Success'), (45, 45, 15.99, 'Pending'),
(46, 46, 9.99, 'Success'), (47, 47, 12.99, 'Success'), (48, 48, 15.99, 'Success'),
(49, 49, 9.99, 'Success'), (50, 50, 12.99, 'Success');
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID) VALUES 
(1, 'Stranger Things', 2016, 'Series', 1),
(2, 'The Irishman', 2019, 'Movie', 1),
(3, 'Extraction', 2020, 'Movie', 1),
(4, 'The Handmaids Tale', 2017, 'Series', 2),
(5, 'Only Murders in the Building', 2021, 'Series', 2),
(6, 'Prey', 2022, 'Movie', 2),
(7, 'The Marvelous Mrs. Maisel', 2017, 'Series', 3),
(8, 'Sound of Metal', 2019, 'Movie', 3),
(9, 'Saltburn', 2023, 'Movie', 3),
(10, 'The Mandalorian', 2019, 'Series', 4),
(11, 'Avengers: Endgame', 2019, 'Movie', 4),
(12, 'Loki', 2021, 'Series', 4),
(13, 'The Last of Us', 2023, 'Series', 5),
(14, 'Dune', 2021, 'Movie', 5),
(15, 'Succession', 2018, 'Series', 5),
(16, 'Top Gun: Maverick', 2022, 'Movie', 6),
(17, 'Yellowstone', 2018, 'Series', 6),
(18, 'Mission: Impossible - Dead Reckoning', 2023, 'Movie', 6),
(19, 'Oppenheimer', 2023, 'Movie', 7),
(20, 'Jurassic World', 2015, 'Movie', 7),
(21, 'The Office', 2005, 'Series', 7),
(22, 'Spider-Man: No Way Home', 2021, 'Movie', 8),
(23, 'The Boys', 2019, 'Series', 8),
(24, 'Gran Turismo', 2023, 'Movie', 8),
(25, 'Everything Everywhere All at Once', 2022, 'Movie', 9),
(26, 'Hereditary', 2018, 'Movie', 9),
(27, 'Euphoria', 2019, 'Series', 9),
(28, 'John Wick: Chapter 4', 2023, 'Movie', 10),
(29, 'The Hunger Games', 2012, 'Movie', 10),
(30, 'Knives Out', 2019, 'Movie', 10),
(31, 'Pathaan', 2023, 'Movie', 11),
(32, 'Dilwale Dulhania Le Jayenge', 1995, 'Movie', 11),
(33, 'War', 2019, 'Movie', 11),
(34, 'Spirited Away', 2001, 'Movie', 12),
(35, 'My Neighbor Totoro', 1988, 'Movie', 12),
(36, 'Princess Mononoke', 1997, 'Movie', 12),
(37, 'Peaky Blinders', 2013, 'Series', 13),
(38, 'Sherlock', 2010, 'Series', 13),
(39, 'Doctor Who', 2005, 'Series', 13),
(40, 'Ted Lasso', 2020, 'Series', 14),
(41, 'The Morning Show', 2019, 'Series', 14),
(42, 'Killers of the Flower Moon', 2023, 'Movie', 14),
(43, 'Jawan', 2023, 'Movie', 15),
(44, 'Chennai Express', 2013, 'Movie', 15),
(45, 'Om Shanti Om', 2007, 'Movie', 15),
(46, 'Inception', 2010, 'Movie', 5),
(47, 'Interstellar', 2014, 'Movie', 5),
(48, 'The Dark Knight', 2008, 'Movie', 5),
(49, 'Squid Game', 2021, 'Series', 1),
(50, 'Money Heist', 2017, 'Series', 1);
INSERT INTO Episode (ContentID, Episode_Number, Episode_Title, Duration_Minutes) VALUES 
-- Stranger Things (ContentID: 1)
(1, 1, 'Chapter One: The Vanishing of Will Byers', 47),
(1, 2, 'Chapter Two: The Weirdo on Maple Street', 55),
(1, 3, 'Chapter Three: Holly, Jolly', 51),
(1, 4, 'Chapter Four: The Body', 50),
(1, 5, 'Chapter Five: The Flea and the Acrobat', 52),

-- The Handmaids Tale (ContentID: 4)
(4, 1, 'Offred', 52),
(4, 2, 'Birth Day', 46),
(4, 3, 'Late', 53),

-- Only Murders in the Building (ContentID: 5)
(5, 1, 'True Crime', 33),
(5, 2, 'Who Is Tim Kono?', 30),
(5, 3, 'How Well Do You Know Your Neighbors?', 35),

-- The Marvelous Mrs. Maisel (ContentID: 7)
(7, 1, 'Pilot', 57),
(7, 2, 'Ya Shivu v Bolshom Dome Pokha', 49),

-- The Mandalorian (ContentID: 10)
(10, 1, 'Chapter 1: The Mandalorian', 39),
(10, 2, 'Chapter 2: The Child', 32),
(10, 3, 'Chapter 3: The Sin', 37),
(10, 4, 'Chapter 4: Sanctuary', 41),

-- Loki (ContentID: 12)
(12, 1, 'Glorious Purpose', 51),
(12, 2, 'The Variant', 54),
(12, 3, 'Lamentis', 42),

-- The Last of Us (ContentID: 13)
(13, 1, 'When Youre Lost in the Darkness', 81),
(13, 2, 'Infected', 52),
(13, 3, 'Long, Long Time', 75),

-- Succession (ContentID: 15)
(15, 1, 'Celebration', 60),
(15, 2, 'Shit Show at the Fuck Factory', 58),

-- Yellowstone (ContentID: 17)
(17, 1, 'Daybreak', 92),
(17, 2, 'Kill the Messenger', 47),

-- The Office (ContentID: 21)
(21, 1, 'Pilot', 23),
(21, 2, 'Diversity Day', 22),
(21, 3, 'Health Care', 22),

-- The Boys (ContentID: 23)
(23, 1, 'The Name of the Game', 60),
(23, 2, 'Cherry', 57),

-- Peaky Blinders (ContentID: 37)
(37, 1, 'Episode 1', 58),
(37, 2, 'Episode 2', 59),

-- Sherlock (ContentID: 38)
(38, 1, 'A Study in Pink', 88),
(38, 2, 'The Blind Banker', 88),

-- Doctor Who (ContentID: 39)
(39, 1, 'Rose', 45),
(39, 2, 'The End of the World', 45),

-- Ted Lasso (ContentID: 40)
(40, 1, 'Pilot', 30),
(40, 2, 'Biscuits', 29),

-- The Morning Show (ContentID: 41)
(41, 1, 'Pilot', 63),

-- Squid Game (ContentID: 49)
(49, 1, 'Red Light, Green Light', 60),
(49, 2, 'Hell', 63),

-- Money Heist (ContentID: 50)
(50, 1, 'Efectuar lo acordado', 47),
(50, 2, 'Imprudencias letales', 45);

INSERT INTO Content_Relation (Parent_ContentID, Child_ContentID, Relation_Type) VALUES 
-- Marvel Cinematic Universe (StudioID 4)
(11, 12, 'Spin-off (Loki from Avengers)'),
(12, 11, 'Prequel (Avengers before Loki)'),
(22, 11, 'Same Universe'),

-- Mission Impossible Series (StudioID 6)
(18, 16, 'Genre Peer (Action)'),

-- John Wick / Hunger Games / Knives Out (StudioID 10)
(29, 30, 'Production Peer'),

-- Bollywood Blockbusters (StudioID 11 & 15)
(31, 33, 'Spy Universe'),
(33, 31, 'Spy Universe'),
(43, 44, 'Lead Actor Collection'),
(44, 45, 'Lead Actor Collection'),
(45, 43, 'Lead Actor Collection'),

-- Christopher Nolan Collection (StudioID 5)
(46, 47, 'Director Collection'),
(47, 48, 'Director Collection'),
(48, 46, 'Director Collection'),

-- Studio Ghibli Collection (StudioID 12)
(34, 35, 'Studio Collection'),
(35, 36, 'Studio Collection'),
(36, 34, 'Studio Collection'),

-- Netflix Originals (StudioID 1)
(1, 49, 'Streaming Peer'),
(49, 50, 'Streaming Peer'),
(50, 1, 'Streaming Peer'),
(2, 3, 'Studio Peer'),

-- Adding more to reach 50 unique relationship pairs
(10, 11, 'Franchise Peer'), (11, 10, 'Franchise Peer'),
(13, 15, 'HBO Peer'), (15, 13, 'HBO Peer'),
(14, 46, 'Sci-Fi Peer'), (46, 14, 'Sci-Fi Peer'),
(19, 47, 'Science Theme Peer'), (47, 19, 'Science Theme Peer'),
(20, 21, 'Universal Peer'), (21, 20, 'Universal Peer'),
(23, 24, 'Sony Peer'), (24, 23, 'Sony Peer'),
(25, 26, 'A24 Peer'), (26, 25, 'A24 Peer'),
(27, 25, 'Studio Peer'), (25, 27, 'Studio Peer'),
(28, 29, 'Action Franchise Peer'), (29, 28, 'Action Franchise Peer'),
(37, 38, 'BBC Peer'), (38, 37, 'BBC Peer'),
(39, 37, 'British TV Peer'), (37, 39, 'British TV Peer'),
(40, 41, 'Apple TV Peer'), (41, 40, 'Apple TV Peer'),
(42, 41, 'Platform Peer'), (41, 42, 'Platform Peer'),
(1, 2, 'Netflix Hub'), (2, 1, 'Netflix Hub'),
(3, 50, 'Action Hub'), (50, 3, 'Action Hub'),
(4, 5, 'Hulu Hub'), (5, 4, 'Hulu Hub');
INSERT INTO Performance (ContentID, PersonID, Character_Role, Contract_Salary) VALUES 
-- Christopher Nolan Collection (StudioID 5)
(46, 3, 'Director', 20000000.00), (46, 10, 'Cobb', 15000000.00),
(47, 3, 'Director', 25000000.00), (48, 3, 'Director', 18000000.00),
(19, 3, 'Director', 30000000.00), (19, 18, 'J. Robert Oppenheimer', 10000000.00),

-- Marvel Cinematic Universe (StudioID 4)
(11, 1, 'Tony Stark / Iron Man', 50000000.00), (12, 18, 'Scarecrow (Cameo)', 500000.00),
(22, 13, 'MJ', 5000000.00),

-- Bollywood Superstars (StudioID 11 & 15)
(31, 8, 'Pathaan', 40000000.00), (31, 19, 'Rubina Mohsin', 15000000.00),
(32, 8, 'Raj Malhotra', 500000.00), (32, 19, 'Simran (Voice)', 100000.00),
(43, 8, 'Azad / Vikram Rathore', 45000000.00), (43, 19, 'Narmada Rai', 20000000.00),
(44, 8, 'Rahul Mithaiwala', 30000000.00), (44, 19, 'Meenalochni', 12000000.00),
(45, 8, 'Om Kapoor', 25000000.00), (45, 19, 'Shantipriya', 5000000.00),

-- Global Icons & Award Winners
(2, 2, 'Director', 15000000.00), (2, 10, 'Frank Sheeran', 12000000.00),
(25, 11, 'Evelyn Wang', 8000000.00), (27, 13, 'Rue Bennett', 2000000.00),
(15, 17, 'Guest Appearance', 500000.00), (40, 17, 'Coach (Cameo)', 300000.00),
(42, 2, 'Director', 20000000.00), (42, 10, 'Ernest Burkhart', 25000000.00),
(28, 14, 'Action Consultant', 2000000.00), (30, 14, 'Detective (Deleted Scene)', 1000000.00),

-- Ghibli & Artistic Direction
(34, 16, 'Director / Writer', 5000000.00), (35, 16, 'Director', 3000000.00),
(36, 16, 'Director', 4000000.00),

-- Reaching 50 entries with various crossovers
(1, 13, 'Voice Talent', 200000.00), (3, 15, 'Action Lead', 10000000.00),
(5, 7, 'Special Appearance', 1500000.00), (7, 7, 'Lead Actress', 12000000.00),
(9, 15, 'Supporting Role', 3000000.00), (10, 5, 'Consulting Director', 2000000.00),
(13, 9, 'Executive Producer', 5000000.00), (14, 20, 'Director', 15000000.00),
(16, 20, 'Second Unit Director', 5000000.00), (17, 14, 'Executive Producer', 8000000.00),
(20, 1, 'Voice Over', 1000000.00), (21, 17, 'Voice Talent', 400000.00),
(23, 4, 'Guest Star', 300000.00), (24, 8, 'Brand Ambassador', 2000000.00),
(26, 9, 'Supporting Role', 1000000.00), (29, 15, 'Lead Role', 5000000.00),
(33, 8, 'Special Cameo', 5000000.00), (37, 18, 'Thomas Shelby', 7000000.00),
(38, 18, 'Villain (Guest)', 2000000.00);
INSERT INTO Ad_Creative (AdID, AdCompanyID, Ad_URL) VALUES 
(7001, 101, 'http://cdn.nike.com/ads/just-do-it-2026.mp4'),
(7002, 101, 'http://cdn.nike.com/ads/running-shoes-v3.mp4'),
(7003, 102, 'http://ads.coca-cola.com/refresh-summer.mp4'),
(7004, 102, 'http://ads.coca-cola.com/holiday-special.mp4'),
(7005, 103, 'http://samsung.com/media/galaxy-s24-reveal.mp4'),
(7006, 103, 'http://samsung.com/media/qled-tv-ad.mp4'),
(7007, 104, 'http://toyota.com/video/camry-hybrid-2026.mp4'),
(7008, 104, 'http://toyota.com/video/offroad-adventure.mp4'),
(7009, 105, 'http://apple.com/v/iphone15-pro-ad.mp4'),
(7010, 105, 'http://apple.com/v/macbook-m3-creative.mp4'),
(7011, 106, 'http://mcdonalds.com/ads/big-mac-promo.mp4'),
(7012, 106, 'http://mcdonalds.com/ads/breakfast-menu.mp4'),
(7013, 107, 'http://visa.com/marketing/contactless-pay.mp4'),
(7014, 108, 'http://pg.com/media/tide-clean-challenge.mp4'),
(7015, 109, 'http://amazon.com/ads/prime-day-deals.mp4'),
(7016, 110, 'http://loreal.com/video/skincare-routine.mp4'),
(7017, 111, 'http://redbull.com/tv/extreme-sports-mix.mp4'),
(7018, 112, 'http://pepsi.com/ads/live-for-now.mp4'),
(7019, 113, 'http://mastercard.com/ads/priceless-moments.mp4'),
(7020, 114, 'http://hyundai.com/media/ioniq-electric.mp4'),
(7021, 115, 'http://netflix-marketing.com/trailers/global-hits.mp4'),
(7022, 116, 'http://airbnb.com/video/beach-getaway.mp4'),
(7023, 117, 'http://nestle.com/ads/kitkat-break.mp4'),
(7024, 118, 'http://microsoft.com/ads/xbox-gamepass.mp4'),
(7025, 119, 'http://disney.com/ads/magic-kingdom-2026.mp4'),
(7026, 120, 'http://unilever.com/media/dove-real-beauty.mp4'),
(7027, 101, 'http://cdn.nike.com/ads/world-cup-special.mp4'),
(7028, 103, 'http://samsung.com/media/foldable-tech.mp4'),
(7029, 105, 'http://apple.com/v/airpods-max-ad.mp4'),
(7030, 107, 'http://visa.com/marketing/travel-rewards.mp4'),
(7031, 109, 'http://amazon.com/ads/aws-cloud-solutions.mp4'),
(7032, 111, 'http://redbull.com/tv/f1-racing-promo.mp4'),
(7033, 115, 'http://netflix-marketing.com/trailers/new-series.mp4'),
(7034, 118, 'http://microsoft.com/ads/surface-laptop.mp4'),
(7035, 120, 'http://unilever.com/media/ben-jerrys-icecream.mp4'),
(7036, 102, 'http://ads.coca-cola.com/zero-sugar-campaign.mp4'),
(7037, 104, 'http://toyota.com/video/safety-sense-demo.mp4'),
(7038, 106, 'http://mcdonalds.com/ads/happy-meal-toys.mp4'),
(7039, 108, 'http://pg.com/media/gillette-shave-care.mp4'),
(7040, 110, 'http://loreal.com/video/hair-color-trends.mp4'),
(7041, 112, 'http://pepsi.com/ads/diet-pepsi-fresh.mp4'),
(7042, 113, 'http://mastercard.com/ads/online-security.mp4'),
(7043, 114, 'http://hyundai.com/media/tucson-suv-2026.mp4'),
(7044, 116, 'http://airbnb.com/video/mountain-cabin.mp4'),
(7045, 117, 'http://nestle.com/ads/maggi-recipes.mp4'),
(7046, 119, 'http://disney.com/ads/cruise-line-promo.mp4'),
(7047, 101, 'http://cdn.nike.com/ads/basketball-legacy.mp4'),
(7048, 103, 'http://samsung.com/media/home-appliances.mp4'),
(7049, 105, 'http://apple.com/v/apple-watch-fitness.mp4'),
(7050, 109, 'http://amazon.com/ads/alexa-smart-home.mp4');
INSERT INTO Ad_Placement (AdID, ContentID, AdCompanyID, Bid_Price, Timestamp_Marker) VALUES 
-- Nike Ads on Sports/Action Content
(7001, 11, 101, 12.50, 600),   -- Just Do It on Avengers at 10 mins
(7002, 16, 101, 15.00, 1200),  -- Running Shoes on Top Gun at 20 mins
(7027, 24, 101, 10.75, 1800),  -- World Cup on Gran Turismo at 30 mins
(7047, 31, 101, 14.20, 2400),  -- Basketball on Pathaan at 40 mins

-- Coca-Cola Ads on Series
(7003, 1, 102, 8.50, 300),     -- Refresh Summer on Stranger Things
(7004, 21, 102, 9.00, 900),    -- Holiday Special on The Office
(7036, 40, 102, 7.75, 450),    -- Zero Sugar on Ted Lasso

-- Samsung Ads on Sci-Fi/Tech Content
(7005, 14, 103, 11.00, 1500),  -- Galaxy S24 on Dune
(7006, 46, 103, 13.50, 2100),  -- QLED TV on Inception
(7028, 47, 103, 12.00, 3000),  -- Foldable Tech on Interstellar
(7048, 12, 103, 9.50, 120),    -- Appliances on Loki

-- Apple Ads on Premium Content
(7009, 15, 105, 25.00, 180),   -- iPhone 15 on Succession
(7010, 41, 105, 22.50, 600),   -- MacBook M3 on The Morning Show
(7029, 42, 105, 20.00, 1200),  -- AirPods on Killers of the Flower Moon
(7049, 13, 105, 18.75, 900),   -- Apple Watch on Last of Us

-- Automotive Ads on Action Movies
(7007, 18, 104, 16.00, 3600),  -- Camry on Mission Impossible
(7008, 28, 104, 14.50, 4200),  -- Offroad on John Wick 4
(7020, 33, 114, 11.20, 1500),  -- Ioniq on War
(7043, 43, 114, 13.00, 2400),  -- Tucson on Jawan

-- Fast Food on Comedy/Series
(7011, 5, 106, 5.50, 300),     -- Big Mac on Only Murders
(7012, 37, 106, 6.00, 1200),   -- Breakfast on Peaky Blinders
(7038, 39, 106, 4.50, 1500),   -- Happy Meal on Doctor Who

-- Financial Services on Documentaries/Drama
(7013, 2, 107, 10.00, 3000),   -- Visa Pay on The Irishman
(7019, 19, 113, 12.00, 1800),  -- Priceless on Oppenheimer
(7042, 27, 113, 9.50, 900),    -- Security on Euphoria

-- E-commerce & Cloud on High-Traffic Series
(7015, 1, 109, 30.00, 1800),   -- Prime Day on Stranger Things
(7031, 23, 109, 28.50, 2400),  -- AWS on The Boys
(7050, 10, 109, 25.00, 1200),  -- Alexa on Mandalorian

-- Personal Care/Cosmetics
(7014, 4, 108, 7.00, 600),     -- Tide on Handmaids Tale
(7016, 7, 110, 8.25, 900),     -- Skincare on Mrs. Maisel
(7040, 50, 110, 9.00, 1200),   -- Hair Color on Money Heist

-- Travel & Tech Mix
(7022, 9, 116, 11.00, 1500),   -- Airbnb on Saltburn
(7044, 48, 116, 12.50, 1800),  -- Cabin on Dark Knight
(7024, 20, 118, 14.00, 2100),  -- Xbox on Jurassic World
(7034, 46, 118, 15.50, 3000),  -- Surface on Inception

-- Nestlé & Unilever
(7023, 49, 117, 6.50, 600),    -- KitKat on Squid Game
(7045, 44, 117, 5.00, 900),    -- Maggi on Chennai Express
(7026, 45, 120, 7.50, 1200),   -- Dove on Om Shanti Om

-- Red Bull Extreme Sports
(7017, 3, 111, 10.00, 600),    -- Extreme on Extraction
(7032, 22, 111, 12.00, 900),   -- F1 Racing on Spider-Man

-- Filling remaining spots for variety
(7025, 36, 119, 9.00, 300),    -- Disney on Mononoke
(7046, 35, 119, 8.50, 450),    -- Cruise on Totoro
(7030, 8, 107, 11.50, 600),    -- Travel Rewards on Sound of Metal
(7033, 29, 115, 13.00, 1200),  -- New Series on Hunger Games
(7035, 30, 120, 10.00, 1500),  -- Ice Cream on Knives Out
(7037, 2, 104, 14.00, 1800),   -- Safety Sense on The Irishman
(7039, 3, 108, 9.50, 2100),    -- Gillette on Extraction
(7041, 14, 112, 10.00, 2400);  -- Diet Pepsi on Dune
INSERT INTO Content_Audio_Languages (ContentID, Language_Name) VALUES 
-- Global Blockbusters (ContentID 11: Avengers, 14: Dune, 19: Oppenheimer)
(11, 'English'), (11, 'Spanish'), (11, 'French'), (11, 'Hindi'), (11, 'Mandarin'),
(14, 'English'), (14, 'Arabic'), (14, 'German'), (14, 'French'),
(19, 'English'), (19, 'Japanese'), (19, 'Russian'), (19, 'German'),

-- Netflix Global Hits (ContentID 1: Stranger Things, 49: Squid Game, 50: Money Heist)
(1, 'English'), (1, 'Spanish'), (1, 'Portuguese'),
(49, 'Korean'), (49, 'English'), (49, 'Hindi'), (49, 'Japanese'),
(50, 'Spanish'), (50, 'English'), (50, 'Italian'), (50, 'French'),

-- Bollywood Hits (ContentID 31: Pathaan, 43: Jawan, 32: DDLJ)
(31, 'Hindi'), (31, 'Telugu'), (31, 'Tamil'), (31, 'Arabic'),
(43, 'Hindi'), (43, 'Tamil'), (43, 'Telugu'), (43, 'Malayalam'),
(32, 'Hindi'), (32, 'English'),

-- Studio Ghibli (ContentID 34: Spirited Away)
(34, 'Japanese'), (34, 'English'), (34, 'French'), (34, 'Mandarin'),

-- British TV (ContentID 37: Peaky Blinders, 38: Sherlock)
(37, 'English'), (37, 'Turkish'),
(38, 'English'), (38, 'Russian'),

-- Apple TV / Other (ContentID 40: Ted Lasso, 46: Inception)
(40, 'English'), (40, 'Spanish'),
(46, 'English'), (46, 'Japanese'), (46, 'German'), (46, 'Hindi'),

-- Additional mapping to reach 50
(2, 'English'), (3, 'English'), (3, 'Hindi'), (4, 'English'), (5, 'English');
INSERT INTO Content_Subtitles (ContentID, Language_Name) VALUES 
-- Global Blockbusters (Avengers, Dune, Oppenheimer)
(11, 'English (CC)'), (11, 'Spanish'), (11, 'French'), (11, 'Hindi'), (11, 'Mandarin'), (11, 'Arabic'),
(14, 'English'), (14, 'Arabic'), (14, 'German'), (14, 'French'), (14, 'Italian'),
(19, 'English'), (19, 'Japanese'), (19, 'Russian'), (19, 'German'), (19, 'Spanish'),

-- Netflix Originals (Squid Game, Money Heist, Stranger Things)
(49, 'Korean'), (49, 'English'), (49, 'Hindi'), (49, 'Japanese'), (49, 'Spanish'),
(50, 'Spanish'), (50, 'English'), (50, 'Italian'), (50, 'French'), (50, 'German'),
(1, 'English'), (1, 'Spanish'), (1, 'Portuguese'), (1, 'Hindi'),

-- Bollywood Hits (Pathaan, Jawan, DDLJ)
(31, 'English'), (31, 'Hindi'), (31, 'Arabic'), (31, 'French'),
(43, 'English'), (43, 'Hindi'), (43, 'Tamil'), (43, 'Telugu'),
(32, 'English'), (32, 'Hindi'),

-- Studio Ghibli (Spirited Away)
(34, 'Japanese'), (34, 'English'), (34, 'French'), (34, 'Mandarin'), (34, 'Spanish'),

-- High-End Series (Succession, The Last of Us, The Office)
(15, 'English'), (15, 'Spanish'),
(13, 'English'), (13, 'Portuguese'),
(21, 'English'), (21, 'Spanish');
INSERT INTO User_Review (ReviewID, UserID, ContentID, Stars) VALUES 
(1, 1, 1, 5), (2, 2, 1, 4), (3, 3, 11, 5), (4, 4, 4, 3), (5, 5, 10, 5),
(6, 6, 21, 5), (7, 7, 7, 4), (8, 8, 19, 5), (9, 9, 25, 4), (10, 10, 12, 3),
(11, 11, 11, 5), (12, 12, 31, 4), (13, 13, 13, 5), (14, 14, 14, 2), (15, 15, 15, 5),
(16, 16, 37, 4), (17, 17, 12, 4), (18, 18, 13, 5), (19, 19, 14, 5), (20, 20, 10, 4),
(21, 21, 1, 3), (22, 22, 31, 5), (23, 23, 23, 4), (24, 24, 19, 5), (25, 25, 2, 5),
(26, 26, 49, 4), (27, 27, 50, 4), (28, 28, 19, 5), (29, 29, 43, 3), (30, 30, 21, 5),
(31, 31, 44, 4), (32, 32, 19, 5), (33, 33, 28, 5), (34, 34, 34, 5), (35, 35, 22, 5),
(36, 36, 11, 4), (37, 37, 48, 5), (38, 38, 11, 5), (39, 39, 47, 5), (40, 40, 31, 4),
(41, 41, 15, 4), (42, 42, 43, 5), (43, 43, 14, 5), (44, 44, 16, 4), (45, 45, 37, 5),
(46, 46, 22, 4), (47, 47, 31, 5), (48, 48, 13, 4), (49, 49, 49, 5), (50, 50, 45, 4);
INSERT INTO Streaming_Platforms (PlatformID, Name, Base_Monthly_Price, Resolution_Supported) VALUES 
(1, 'Netflix Global', 15.49, '4K'),
(2, 'Disney+ Hotstar', 12.99, '4K'),
(3, 'Amazon Prime Video', 14.99, '4K'),
(4, 'Hulu', 7.99, '1080p'),
(5, 'HBO Max', 15.99, '4K'),
(6, 'Apple TV+', 9.99, '4K'),
(7, 'Paramount+', 11.99, '4K'),
(8, 'Peacock Premium', 5.99, '1080p'),
(9, 'Crunchyroll Premium', 7.99, '1080p'),
(10, 'Sony LIV', 8.50, '1080p'),
(11, 'ZEE5 Global', 6.99, '1080p'),
(12, 'Mubi Indie', 10.99, '2K'),
(13, 'Shudder Horror', 5.99, '1080p'),
(14, 'BritBox', 8.99, '1080p'),
(15, 'Discovery+', 4.99, '1080p'),
(16, 'Rakuten TV', 0.00, '4K'),
(17, 'Crave Canada', 19.99, '4K'),
(18, 'Stan Australia', 10.00, '4K'),
(19, 'Viaplay Nordic', 13.50, '2K'),
(20, 'JioCinema Premium', 2.50, '4K'),
(21, 'FuboTV', 74.99, '4K'),
(22, 'Sling TV', 40.00, '1080p'),
(23, 'YouTube Premium', 13.99, '4K'),
(24, 'DAZN Sports', 19.99, '1080p'),
(25, 'Eurosport Pass', 6.99, '1080p'),
(26, 'Funimation', 5.99, '1080p'),
(27, 'HIDIVE Anime', 4.99, '1080p'),
(28, 'CuriosityStream', 3.99, '4K'),
(29, 'Tubi (Ad-Supported)', 0.00, '720p'),
(30, 'Pluto TV', 0.00, '720p'),
(31, 'Kanopy', 0.00, '1080p'),
(32, 'Vudu', 0.00, '4K'),
(33, 'AMC+', 8.99, '1080p'),
(34, 'Starz', 9.99, '4K'),
(35, 'Showtime', 10.99, '4K'),
(36, 'iQIYI International', 6.99, '4K'),
(37, 'Viki Rakuten', 4.99, '1080p'),
(38, 'Shahid MBC', 8.49, '4K'),
(39, 'GloboPlay', 9.00, '4K'),
(40, 'Sky Go', 15.00, '1080p'),
(41, 'Now TV', 12.00, '1080p'),
(42, 'RTL+ Premium', 6.99, '1080p'),
(43, 'Canal+ Digital', 20.00, '4K'),
(44, 'Movistar Plus', 18.00, '4K'),
(45, 'Voot Select', 4.00, '1080p'),
(46, 'Alt Balaji', 3.00, '720p'),
(47, 'Hayu Reality', 6.99, '1080p'),
(48, 'BFI Player', 7.50, '1080p'),
(49, 'Criterion Channel', 10.99, '1080p'),
(50, 'StreamPulse Internal', 0.00, '8K');
INSERT INTO Content_Provider_Bridge (ContentID, PlatformID, Is_Exclusive) VALUES 
-- Netflix Originals (ContentID 1, 2, 3, 49, 50)
(1, 1, TRUE),   -- Stranger Things on Netflix (Exclusive)
(2, 1, TRUE),   -- The Irishman on Netflix
(3, 1, TRUE),   -- Extraction on Netflix
(49, 1, TRUE),  -- Squid Game on Netflix
(50, 1, TRUE),  -- Money Heist on Netflix

-- Disney+ / Hotstar (ContentID 10, 11, 12, 22)
(10, 2, TRUE),  -- The Mandalorian on Disney+
(11, 2, FALSE), -- Avengers on Disney+
(11, 23, FALSE),-- Avengers also on YouTube (Rent)
(12, 2, TRUE),  -- Loki on Disney+
(22, 2, FALSE), -- Spider-Man on Disney+
(22, 32, FALSE),-- Spider-Man on Vudu

-- HBO Max / Warner (ContentID 13, 14, 15, 19, 46, 47, 48)
(13, 5, TRUE),  -- Last of Us on HBO Max
(14, 5, FALSE), -- Dune on HBO Max
(14, 3, FALSE), -- Dune also on Prime Video
(15, 5, TRUE),  -- Succession on HBO Max
(19, 5, FALSE), -- Oppenheimer on HBO Max
(46, 5, FALSE), -- Inception on HBO Max
(46, 1, FALSE), -- Inception on Netflix
(47, 5, FALSE), -- Interstellar on HBO Max
(48, 5, FALSE), -- Dark Knight on HBO Max

-- Amazon Prime (ContentID 7, 8, 9, 23)
(7, 3, TRUE),   -- Mrs. Maisel on Prime
(8, 3, TRUE),   -- Sound of Metal on Prime
(9, 3, TRUE),   -- Saltburn on Prime
(23, 3, TRUE),  -- The Boys on Prime

-- Apple TV+ (ContentID 40, 41, 42)
(40, 6, TRUE),  -- Ted Lasso on Apple TV
(41, 6, TRUE),  -- Morning Show on Apple TV
(42, 6, TRUE),  -- Killers of Flower Moon on Apple TV

-- Hulu / Paramount (ContentID 4, 5, 6, 16, 17, 18)
(4, 4, TRUE),   -- Handmaids Tale on Hulu
(5, 4, TRUE),   -- Only Murders on Hulu
(6, 4, TRUE),   -- Prey on Hulu
(16, 7, FALSE), -- Top Gun on Paramount
(17, 7, TRUE),  -- Yellowstone on Paramount
(18, 7, TRUE),  -- Mission Impossible on Paramount

-- Bollywood / Regional (ContentID 31, 32, 43, 44, 45)
(31, 3, FALSE), -- Pathaan on Prime
(31, 20, FALSE),-- Pathaan on JioCinema
(32, 3, FALSE), -- DDLJ on Prime
(43, 1, FALSE), -- Jawan on Netflix
(44, 1, FALSE), -- Chennai Express on Netflix
(45, 1, FALSE), -- Om Shanti Om on Netflix

-- Anime & International (ContentID 34, 35, 36, 37, 38, 39)
(34, 1, FALSE), -- Spirited Away on Netflix
(34, 5, FALSE), -- Spirited Away on HBO Max (US)
(35, 1, FALSE), -- My Neighbor Totoro on Netflix
(36, 1, FALSE), -- Princess Mononoke on Netflix
(37, 1, FALSE), -- Peaky Blinders on Netflix
(37, 13, FALSE),-- Peaky Blinders on BBC/BritBox
(38, 1, FALSE), -- Sherlock on Netflix
(39, 14, FALSE),-- Doctor Who on BritBox
(39, 2, FALSE); -- Doctor Who on Disney+ (International)
INSERT INTO Genre_Lookup (GenreID, Genre_Name) VALUES 
(1, 'Action'), (2, 'Adventure'), (3, 'Animation'), (4, 'Biography'), 
(5, 'Comedy'), (6, 'Crime'), (7, 'Documentary'), (8, 'Drama'), 
(9, 'Family'), (10, 'Fantasy'), (11, 'Film-Noir'), (12, 'History'), 
(13, 'Horror'), (14, 'Music'), (15, 'Musical'), (16, 'Mystery'), 
(17, 'Romance'), (18, 'Sci-Fi'), (19, 'Short'), (20, 'Sport'), 
(21, 'Thriller'), (22, 'War'), (23, 'Western'), (24, 'Psychological'),
(25, 'Supernatural'), (26, 'Slasher'), (27, 'Zombie'), (28, 'Post-Apocalyptic'),
(29, 'Cyberpunk'), (30, 'Steampunk'), (31, 'Space-Opera'), (32, 'Superhero'),
(33, 'Legal Drama'), (34, 'Medical Drama'), (35, 'Political Thriller'), (36, 'Spy'),
(37, 'Coming-of-Age'), (38, 'Satire'), (39, 'Dark Comedy'), (40, 'Mockumentary'),
(41, 'True Crime'), (42, 'Nature'), (43, 'Travel'), (44, 'Reality-TV'),
(45, 'Game-Show'), (46, 'Talk-Show'), (47, 'Neo-Noir'), (48, 'Kaiju'),
(49, 'Period Piece'), (50, 'Experimental');
INSERT INTO Content_Genre_Map (ContentID, GenreID) VALUES 
-- Sci-Fi & Horror Hits
(1, 18), (1, 13), (1, 25), 
(49, 21), (49, 8),         
(50, 6), (50, 21),         

-- Action & Superhero Blockbusters
(11, 1), (11, 32), (11, 18), 
(10, 1), (10, 31),           
(12, 2), (12, 10),         -- Typo Fixed Here (Removed extra comma)
(22, 1), (22, 32),           
(18, 1), (18, 36),           
(28, 1), (28, 6),            

-- Prestige Drama & Thriller
(13, 8), (13, 28), (13, 13), 
(15, 8), (15, 38),           
(19, 8), (19, 12),           
(14, 18), (14, 2),           
(46, 18), (46, 21),          
(47, 18), (47, 8),           
(48, 1), (48, 6), (48, 8),   

-- Bollywood & Animation
(31, 1), (31, 36),           
(43, 1), (43, 21),           
(32, 17), (32, 15),          
(34, 3), (34, 10),           
(35, 3), (35, 9),            

-- Comedy & Others
(21, 5), (21, 40),           
(40, 5), (40, 20),           
(5, 5), (5, 16),             
(25, 10), (25, 39),          
(7, 5), (7, 8);
-- Step 1: Turn off foreign key checks
SET FOREIGN_KEY_CHECKS = 0;


-- Step 2: Empty the table
TRUNCATE TABLE Production_House;
INSERT INTO Production_House (StudioID, Studio_Name, Headquarters, Founding_Date) VALUES 
(1, 'Netflix Studios', 'Los Gatos, USA', '1997-08-29'),
(2, '20th Century Studios', 'Los Angeles, USA', '1935-05-31'),
(3, 'Amazon MGM Studios', 'Beverly Hills, USA', '1924-04-17'),
(4, 'Marvel Studios', 'Burbank, USA', '1993-12-07'),
(5, 'Warner Bros. Pictures', 'Burbank, USA', '1923-04-04'),
(6, 'Paramount Pictures', 'Hollywood, USA', '1912-05-08'),
(7, 'Universal Pictures', 'Universal City, USA', '1912-06-08'),
(8, 'Sony Pictures', 'Culver City, USA', '1987-12-21'),
(9, 'A24', 'New York City, USA', '2012-08-20'),
(10, 'Lionsgate Films', 'Santa Monica, USA', '1997-07-10'),
(11, 'Yash Raj Films', 'Mumbai, India', '1970-09-27'),
(12, 'Studio Ghibli', 'Koganei, Japan', '1985-06-15'),
(13, 'BBC Film', 'London, UK', '1990-06-18'),
(14, 'Apple Studios', 'Cupertino, USA', '2019-11-01'),
(15, 'Red Chillies Entertainment', 'Mumbai, India', '2002-05-07'),
(16, 'Lucasfilm', 'San Francisco, USA', '1971-12-10'),
(17, 'Pixar Animation Studios', 'Emeryville, USA', '1986-02-03'),
(18, 'DreamWorks Animation', 'Glendale, USA', '1994-10-12'),
(19, 'StudioCanal', 'Issy-les-Moulineaux, France', '1988-01-01'),
(20, 'Toei Animation', 'Tokyo, Japan', '1948-01-23'),
(21, 'Relativity Media', 'Beverly Hills, USA', '2004-05-01'),
(22, 'Focus Features', 'New York City, USA', '2002-05-01'),
(23, 'Searchlight Pictures', 'Los Angeles, USA', '1994-01-01'),
(24, 'Blumhouse Productions', 'Los Angeles, USA', '2000-01-01'),
(25, 'Bad Robot Productions', 'Santa Monica, USA', '1998-01-01'),
(26, 'Legendary Entertainment', 'Burbank, USA', '2000-01-01'),
(27, 'New Line Cinema', 'Burbank, USA', '1967-01-01'),
(28, 'Illumination Entertainment', 'Santa Monica, USA', '2007-01-01'),
(29, 'Skydance Media', 'Santa Monica, USA', '2006-01-01'),
(30, 'Amblin Entertainment', 'Universal City, USA', '1981-01-01'),
(31, 'Dharma Productions', 'Mumbai, India', '1976-01-01'),
(32, 'Eros International', 'Mumbai, India', '1977-01-01'),
(33, 'MAPPA', 'Tokyo, Japan', '2011-06-14'),
(34, 'Ufotable', 'Tokyo, Japan', '2000-10-01'),
(35, 'Plan B Entertainment', 'Beverly Hills, USA', '2001-01-01'),
(36, 'Village Roadshow Pictures', 'Melbourne, Australia', '1989-01-01'),
(37, 'PolyGram Filmed Ent.', 'London, UK', '1980-01-01'),
(38, 'Gaumont Film Company', 'Neuilly-sur-Seine, France', '1895-01-01'),
(39, 'Pathé', 'Paris, France', '1896-01-01'),
(40, 'Constantin Film', 'Munich, Germany', '1950-01-01'),
(41, 'Wanda Pictures', 'Beijing, China', '2009-01-01'),
(42, 'CJ ENM', 'Seoul, South Korea', '1994-01-01'),
(43, 'TSG Entertainment', 'New York City, USA', '2012-01-01'),
(44, 'Annapurna Pictures', 'West Hollywood, USA', '2011-01-01'),
(45, 'Working Title Films', 'London, UK', '1983-01-01'),
(46, 'Imagine Entertainment', 'Beverly Hills, USA', '1985-01-01'),
(47, 'The Weinstein Company', 'New York City, USA', '2005-01-01'),
(48, 'Miramax', 'Los Angeles, USA', '1979-01-01'),
(49, 'Summit Entertainment', 'Santa Monica, USA', '1991-01-01'),
(50, 'StreamPulse Originals', 'San Jose, USA', '2024-01-01');

-- Step 3: Turn foreign key checks back on (CRITICAL)
SET FOREIGN_KEY_CHECKS = 1;
TRUNCATE TABLE Cast_crew;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Cast_crew;
INSERT INTO Cast_Crew (PersonID, Legal_Name, Nationality, Biography) VALUES 
(1, 'Robert Downey Jr.', 'American', 'Famous for playing Iron Man in the MCU.'),
(2, 'Martin Scorsese', 'American', 'Legendary director of The Irishman and Goodfellas.'),
(3, 'Christopher Nolan', 'British-American', 'Visionary director known for Inception and Oppenheimer.'),
(4, 'Meryl Streep', 'American', 'Highly decorated actress with numerous Oscar wins.'),
(5, 'Pedro Pascal', 'Chilean-American', 'Star of The Last of Us and The Mandalorian.'),
(6, 'Greta Gerwig', 'American', 'Acclaimed director of Lady Bird and Barbie.'),
(7, 'Mindy Kaling', 'American', 'Writer and actress known for The Office.'),
(8, 'Shah Rukh Khan', 'Indian', 'The "King of Bollywood" with a global fan base.'),
(9, 'Zendaya', 'American', 'Award-winning actress from Euphoria and Dune.'),
(10, 'Leonardo DiCaprio', 'American', 'Oscar winner known for The Revenant and Inception.'),
(11, 'Michelle Yeoh', 'Malaysian', 'Action icon and Oscar winner for Everything Everywhere.'),
(12, 'Bong Joon-ho', 'South Korean', 'Director of the Oscar-winning film Parasite.'),
(13, 'Tom Cruise', 'American', 'Action star famous for Mission: Impossible stunts.'),
(14, 'Margot Robbie', 'Australian', 'Versatile actress known for Barbie and Harley Quinn.'),
(15, 'Chris Hemsworth', 'Australian', 'Well known for playing Thor in the Marvel movies.'),
(16, 'Hayao Miyazaki', 'Japanese', 'Co-founder of Studio Ghibli and animation legend.'),
(17, 'Florence Pugh', 'British', 'Rising star known for Midsommar and Black Widow.'),
(18, 'Cillian Murphy', 'Irish', 'Lead actor of Oppenheimer and Peaky Blinders.'),
(19, 'Deepika Padukone', 'Indian', 'Leading Bollywood actress and international star.'),
(20, 'Denis Villeneuve', 'Canadian', 'Director known for Dune and Arrival.'),
(21, 'Viola Davis', 'American', 'EGOT winner and powerhouse dramatic actress.'),
(22, 'Denzel Washington', 'American', 'Two-time Oscar winner with a legendary career.'),
(23, 'Emma Stone', 'American', 'Acclaimed actress from La La Land and Poor Things.'),
(24, 'Rian Johnson', 'American', 'Director of Knives Out and Glass Onion.'),
(25, 'Olivia Colman', 'British', 'Oscar winner known for The Favourite and The Crown.'),
(26, 'Joaquin Phoenix', 'American', 'Method actor known for Joker and Gladiator.'),
(27, 'Cate Blanchett', 'Australian', 'Award-winning actress known for Tár.'),
(28, 'Jordan Peele', 'American', 'Director who redefined horror with Get Out.'),
(29, 'Steven Spielberg', 'American', 'One of the most influential directors in history.'),
(30, 'Lady Gaga', 'American', 'Multi-talented singer and Oscar-nominated actress.'),
(31, 'Daniel Kaluuya', 'British', 'Star of Get Out and Judas and the Black Messiah.'),
(32, 'Ryan Gosling', 'Canadian', 'Star of Barbie, La La Land, and Drive.'),
(33, 'Saoirse Ronan', 'Irish', 'Four-time Oscar nominee known for Little Women.'),
(34, 'Idris Elba', 'British', 'Versatile actor from Luther and The Wire.'),
(35, 'Ana de Armas', 'Cuban-Spanish', 'Star of Knives Out and Blonde.'),
(36, 'Taika Waititi', 'New Zealand', 'Director and actor known for Jojo Rabbit.'),
(37, 'Penélope Cruz', 'Spanish', 'Acclaimed international actress and Oscar winner.'),
(38, 'Mads Mikkelsen', 'Danish', 'Known for Hannibal and Casino Royale.'),
(39, 'Tilda Swinton', 'British', 'Versatile actress known for arthouse and blockbusters.'),
(40, 'Guillermo del Toro', 'Mexican', 'Director known for Pan''s Labyrinth and Pinocchio.'),
(41, 'Timothée Chalamet', 'American-French', 'Star of Dune and Wonka.'),
(42, 'Anya Taylor-Joy', 'British-American', 'Lead actress of The Queen''s Gambit.'),
(43, 'Austin Butler', 'American', 'Breakout star of Elvis.'),
(44, 'Ke Huy Quan', 'Vietnamese-American', 'Oscar winner for Everything Everywhere All at Once.'),
(45, 'Barry Keoghan', 'Irish', 'Rising star from Saltburn and The Banshees of Inisherin.'),
(46, 'Greta Lee', 'American', 'Lead actress of Past Lives.'),
(47, 'Steven Yeun', 'South Korean-American', 'Known for Minari and Beef.'),
(48, 'Jenna Ortega', 'American', 'Star of the hit series Wednesday.'),
(49, 'Hwang Dong-hyuk', 'South Korean', 'Creator and director of Squid Game.'),
(50, 'Wes Anderson', 'American', 'Director known for his distinct visual style.');
SET FOREIGN_KEY_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Advertiser;
INSERT INTO Advertiser (AdCompanyID, Company_Name, Industry) VALUES 
(101, 'Nike', 'Apparel & Sports'), (102, 'Coca-Cola', 'Beverages'),
(103, 'Samsung', 'Electronics'), (104, 'Toyota', 'Automotive'),
(105, 'Apple Inc.', 'Technology'), (106, 'McDonalds', 'Fast Food'),
(107, 'Visa', 'Financial Services'), (108, 'Procter & Gamble', 'Consumer Goods'),
(109, 'Amazon', 'E-commerce'), (110, 'L Oreal', 'Personal Care'),
(111, 'Red Bull', 'Beverages'), (112, 'PepsiCo', 'Beverages'),
(113, 'Mastercard', 'Financial Services'), (114, 'Hyundai', 'Automotive'),
(115, 'Netflix Marketing', 'Entertainment'), (116, 'Airbnb', 'Travel'),
(117, 'Nestle', 'Food & Beverage'), (118, 'Microsoft', 'Technology'),
(119, 'Disney Parks', 'Entertainment'), (120, 'Unilever', 'Consumer Goods'),
(121, 'Ford', 'Automotive'), (122, 'Starbucks', 'Beverages'),
(123, 'American Express', 'Financial Services'), (124, 'Adidas', 'Apparel'),
(125, 'Sony Interactive', 'Gaming'), (126, 'Pfizer', 'Healthcare'),
(127, 'Johnson & Johnson', 'Healthcare'), (128, 'Walmart', 'Retail'),
(129, 'Target', 'Retail'), (130, 'Dell', 'Technology'),
(131, 'HP Inc.', 'Technology'), (132, 'Uber', 'Transportation'),
(133, 'Lyft', 'Transportation'), (134, 'Expedia', 'Travel'),
(135, 'Booking.com', 'Travel'), (136, 'Adobe', 'Software'),
(137, 'Salesforce', 'Software'), (138, 'Kellogg s', 'Food'),
(139, 'General Mills', 'Food'), (140, 'Marriott', 'Hospitality'),
(141, 'Hilton', 'Hospitality'), (142, 'FedEx', 'Logistics'),
(143, 'UPS', 'Logistics'), (144, 'IKEA', 'Home Furnishing'),
(145, 'H&M', 'Apparel'), (146, 'Zara', 'Apparel'),
(147, 'Lego', 'Toys'), (148, 'Mattel', 'Toys'),
(149, 'Bose', 'Electronics'), (150, 'Nintendo', 'Gaming');
SET FOREIGN_KEY_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Award ;
INSERT INTO Award (AwardID, Organization, Award_Year, Category_Name) VALUES 
(1, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Picture'),
(2, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Director'),
(3, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Actor'),
(4, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Actress'),
(5, 'Academy of Motion Picture Arts and Sciences', 2023, 'Best Picture'),
(6, 'Academy of Motion Picture Arts and Sciences', 2023, 'Best Supporting Actor'),
(7, 'Television Academy', 2023, 'Outstanding Drama Series'),
(8, 'Television Academy', 2023, 'Outstanding Comedy Series'),
(9, 'Television Academy', 2023, 'Outstanding Lead Actor in a Drama'),
(10, 'Television Academy', 2023, 'Outstanding Lead Actress in a Drama'),
(11, 'Hollywood Foreign Press Association', 2024, 'Best Motion Picture – Drama'),
(12, 'Hollywood Foreign Press Association', 2024, 'Best Motion Picture – Musical or Comedy'),
(13, 'British Academy of Film and Television Arts', 2024, 'Best Film'),
(14, 'British Academy of Film and Television Arts', 2024, 'Outstanding British Film'),
(15, 'Academy of Motion Picture Arts and Sciences', 2022, 'Best Animated Feature'),
(16, 'Academy of Motion Picture Arts and Sciences', 2021, 'Best International Feature Film'),
(17, 'Television Academy', 2022, 'Outstanding Limited or Anthology Series'),
(18, 'Television Academy', 2022, 'Outstanding Writing for a Comedy Series'),
(19, 'Screen Actors Guild', 2024, 'Outstanding Performance by a Cast in a Motion Picture'),
(20, 'Screen Actors Guild', 2024, 'Outstanding Performance by an Ensemble in a Drama Series'),
(21, 'Cannes Film Festival', 2023, 'Palme d''Or'),
(22, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Visual Effects'),
(23, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Original Score'),
(24, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Adapted Screenplay'),
(25, 'Television Academy', 2023, 'Outstanding Directing for a Drama Series'),
(26, 'Television Academy', 2023, 'Outstanding Guest Actor in a Drama Series'),
(27, 'Academy of Motion Picture Arts and Sciences', 2020, 'Best Picture'),
(28, 'Academy of Motion Picture Arts and Sciences', 1994, 'Best Picture'),
(29, 'Academy of Motion Picture Arts and Sciences', 1972, 'Best Picture'),
(30, 'British Academy of Film and Television Arts', 2023, 'Best Director'),
(31, 'Hollywood Foreign Press Association', 2023, 'Best Screenplay – Motion Picture'),
(32, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Cinematography'),
(33, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Costume Design'),
(34, 'Television Academy', 2021, 'Outstanding Lead Actress in a Comedy'),
(35, 'Academy of Motion Picture Arts and Sciences', 2019, 'Best Animated Feature'),
(36, 'Academy of Motion Picture Arts and Sciences', 2017, 'Best Picture'),
(37, 'Academy of Motion Picture Arts and Sciences', 2010, 'Best Director'),
(38, 'Television Academy', 2020, 'Outstanding Lead Actor in a Limited Series'),
(39, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Sound'),
(40, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Film Editing'),
(41, 'Hollywood Foreign Press Association', 2024, 'Best Original Song'),
(42, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Documentary Feature'),
(43, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Live Action Short Film'),
(44, 'Television Academy', 2023, 'Outstanding Cinematography for a Series'),
(45, 'Television Academy', 2023, 'Outstanding Music Composition for a Series'),
(46, 'British Academy of Film and Television Arts', 2024, 'Best Documentary'),
(47, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Production Design'),
(48, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Makeup and Hairstyling'),
(49, 'Television Academy', 2023, 'Outstanding Production Design for a Narrative Period Program'),
(50, 'Academy of Motion Picture Arts and Sciences', 2024, 'Best Animated Short Film');
SET FOREIGN_KEY_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE CDN_Server;
INSERT INTO CDN_Server (ServerID, Region, IP_Address, Storage_Capacity_TB) VALUES 
(1, 'North America (East)', '192.168.1.1', 500),
(2, 'North America (West)', '192.168.1.2', 750),
(3, 'Europe (West)', '10.0.0.1', 600),
(4, 'Europe (North)', '10.0.0.2', 450),
(5, 'Asia Pacific (Tokyo)', '172.16.0.1', 1000),
(6, 'Asia Pacific (Mumbai)', '172.16.0.2', 1200),
(7, 'South America (Brazil)', '191.168.1.5', 300),
(8, 'Africa (Cape Town)', '196.25.1.1', 250),
(9, 'Australia (Sydney)', '203.0.113.1', 400),
(10, 'Middle East (Dubai)', '94.200.10.1', 500),
(11, 'North America (Central)', '192.168.2.1', 550),
(12, 'Europe (Central)', '10.1.0.1', 800),
(13, 'Asia Pacific (Singapore)', '172.17.0.1', 950),
(14, 'Asia Pacific (Seoul)', '172.18.0.1', 700),
(15, 'North America (Canada)', '192.168.3.1', 400),
(16, 'Europe (London)', '10.2.0.1', 650),
(17, 'Europe (Paris)', '10.3.0.1', 600),
(18, 'Asia Pacific (Hong Kong)', '172.19.0.1', 850),
(19, 'South America (Chile)', '191.169.2.1', 200),
(20, 'Middle East (Israel)', '94.201.11.5', 300),
(21, 'North America (East 2)', '192.168.1.10', 500),
(22, 'North America (West 2)', '192.168.1.20', 750),
(23, 'Europe (West 2)', '10.0.0.10', 600),
(24, 'Europe (North 2)', '10.0.0.20', 450),
(25, 'Asia Pacific (Osaka)', '172.16.1.1', 1000),
(26, 'Asia Pacific (Delhi)', '172.16.1.2', 1200),
(27, 'South America (Argentina)', '191.168.2.5', 300),
(28, 'Africa (Nairobi)', '196.26.2.1', 250),
(29, 'Australia (Melbourne)', '203.0.114.1', 400),
(30, 'Middle East (Riyadh)', '94.202.12.1', 500),
(31, 'North America (Mexico)', '192.168.4.1', 350),
(32, 'Europe (Berlin)', '10.4.0.1', 800),
(33, 'Asia Pacific (Bangkok)', '172.20.0.1', 550),
(34, 'Asia Pacific (Jakarta)', '172.21.0.1', 900),
(35, 'North America (Miami)', '192.168.5.1', 450),
(36, 'Europe (Madrid)', '10.5.0.1', 500),
(37, 'Europe (Stockholm)', '10.6.0.1', 400),
(38, 'Asia Pacific (Taiwan)', '172.22.0.1', 750),
(39, 'South America (Colombia)', '191.170.3.1', 250),
(40, 'Middle East (Turkey)', '94.203.13.5', 400),
(41, 'US Government (East)', '192.168.100.1', 1000),
(42, 'US Government (West)', '192.168.100.2', 1000),
(43, 'China (Beijing)', '1.1.1.1', 2000),
(44, 'China (Shanghai)', '1.1.1.2', 2000),
(45, 'India (Chennai)', '172.16.2.1', 800),
(46, 'India (Bangalore)', '172.16.2.2', 900),
(47, 'Russia (Moscow)', '95.161.1.1', 500),
(48, 'Italy (Milan)', '10.7.0.1', 450),
(49, 'Netherlands (Amsterdam)', '10.8.0.1', 1100),
(50, 'Global Backup (Iceland)', '193.10.1.1', 1500);
SET FOREIGN_KEY_CHECKS = 1;
CREATE VIEW Master_Catalog AS
SELECT 
    m.Title, 
    m.Release_Year, 
    p.Studio_Name, 
    g.Genre_Name,
    m.Content_Type
FROM Media_Content m
JOIN Production_House p ON m.StudioID = p.StudioID
JOIN Content_Genre_Map cgm ON m.ContentID = cgm.ContentID
JOIN Genre_Lookup g ON cgm.GenreID = g.GenreID;

-- To test it:
SELECT * FROM Master_Catalog WHERE Genre_Name = 'Sci-Fi';
SELECT 
    CONCAT(u.First_Name, ' ', u.Last_Name) AS Full_Name, -- Combining your actual columns
    vd.Model AS Device_Used, 
    mc.Title AS Movie_Watched, 
    ur.Stars AS Rating_Given
FROM User_Account u
JOIN Viewing_Device vd ON u.UserID = vd.UserID
JOIN User_Review ur ON u.UserID = ur.UserID
JOIN Media_Content mc ON ur.ContentID = mc.ContentID
ORDER BY ur.Stars DESC;
SELECT 
    adv.Company_Name, 
    adv.Industry, 
    mc.Title AS Placed_In, 
    ap.Bid_Price, 
    ap.Timestamp_Marker
FROM Advertiser adv
JOIN Ad_Placement ap ON adv.AdCompanyID = ap.AdCompanyID
JOIN Media_Content mc ON ap.ContentID = mc.ContentID
WHERE ap.Bid_Price > 15.00
ORDER BY ap.Bid_Price DESC;
SELECT 
    mc.Title, 
    cs.Region AS Server_Location, 
    cal.Language_Name AS Audio_Track,
    sp.Name AS Streaming_On
FROM Media_Content mc
JOIN Content_Audio_Languages cal ON mc.ContentID = cal.ContentID
JOIN Content_Provider_Bridge cpb ON mc.ContentID = cpb.ContentID
JOIN Streaming_Platforms sp ON cpb.PlatformID = sp.PlatformID
CROSS JOIN CDN_Server cs -- This simulates global distribution logic
WHERE mc.Title = 'Stranger Things' 
LIMIT 10;
SELECT 
    (SELECT SUM(Amount) FROM Payment_Transaction WHERE Status = 'Success') AS Total_Revenue_USD,
    (SELECT AVG(Base_Monthly_Price) FROM Streaming_Platforms) AS Avg_Market_Subscription_Fee,
    (SELECT COUNT(*) FROM Support_Ticket WHERE Status = 'Open') AS Active_Support_Incidents,
    (SELECT COUNT(DISTINCT UserID) FROM Payment_Transaction WHERE Status = 'Success') AS Total_Paying_Customers;
    CREATE VIEW High_Value_Ads AS
SELECT 
    A.Company_Name,
    AC.Ad_URL,
    M.Title AS Featured_In,
    AP.Bid_Price
FROM Ad_Placement AP
JOIN Advertiser A ON AP.AdCompanyID = A.AdCompanyID
JOIN Ad_Creative AC ON AP.AdID = AC.AdID
JOIN Media_Content M ON AP.ContentID = M.ContentID
WHERE AP.Bid_Price > 20.00;

-- Test the view
SELECT * FROM High_Value_Ads;
CREATE OR REPLACE VIEW Master_Catalog AS
SELECT 
    m.ContentID,      -- This is the missing piece!
    m.Title, 
    m.Release_Year, 
    p.Studio_Name, 
    p.StudioID,
    g.Genre_Name,
    m.Content_Type
FROM Media_Content m
JOIN Production_House p ON m.StudioID = p.StudioID
JOIN Content_Genre_Map cgm ON m.ContentID = cgm.ContentID
JOIN Genre_Lookup g ON cgm.GenreID = g.GenreID;
SELECT 
    m.Title, 
    m.Release_Year, 
    m.Studio_Name, 
    cc.Legal_Name AS Actor_Name, 
    p.Character_Role,
    sp.Name AS Platform_Name
FROM Master_Catalog m
LEFT JOIN Performance p ON m.ContentID = p.ContentID
LEFT JOIN Cast_Crew cc ON p.PersonID = cc.PersonID
LEFT JOIN Content_Provider_Bridge cpb ON m.ContentID = cpb.ContentID
LEFT JOIN Streaming_Platforms sp ON cpb.PlatformID = sp.PlatformID

WHERE m.Title = 'Inception';
-- 1. Turn off "Safe Update" mode
SET SQL_SAFE_UPDATES = 0;

-- 2. Run your updates (I've fixed the links for you)
UPDATE Media_Content SET Poster_URL = 'https://image.tmdb.org/t/p/w500/1BIoJvCnqzPsu8o4brFYXYqqi2n.jpg' WHERE Title = 'The Mandalorian';
UPDATE Media_Content SET Poster_URL = 'https://image.tmdb.org/t/p/w500/or06vS3eeIU3psn3MhgeZfk8aR4.jpg' WHERE Title = 'Avengers: Endgame';
UPDATE Media_Content SET Poster_URL = 'https://image.tmdb.org/t/p/w500/f89U3Y9L9u2M0O7MjaYvM7z9z9z.jpg' WHERE Title = 'Inception';
UPDATE Media_Content SET Poster_URL = 'https://image.tmdb.org/t/p/w500/8S969U7X2Ois4OqK15G2VqWqK8W.jpg' WHERE Title = 'Squid Game';

-- 3. Update the Master_Catalog View to make sure it includes the Poster_URL column
CREATE OR REPLACE VIEW Master_Catalog AS
SELECT 
    m.ContentID,
    m.Title, 
    m.Release_Year, 
    p.Studio_Name, 
    g.Genre_Name,
    m.Content_Type,
    m.Poster_URL
FROM Media_Content m
JOIN Production_House p ON m.StudioID = p.StudioID
JOIN Content_Genre_Map cgm ON m.ContentID = cgm.ContentID
JOIN Genre_Lookup g ON cgm.GenreID = g.GenreID;

-- 4. Turn "Safe Update" mode back on
SET SQL_SAFE_UPDATES = 1;
CREATE OR REPLACE VIEW Master_Catalog AS
SELECT 
    m.ContentID,
    m.Title, 
    m.Release_Year, 
    p.Studio_Name, 
    g.Genre_Name,
    m.Content_Type,
    m.Poster_URL  -- <--- THIS MUST BE HERE
FROM Media_Content m
JOIN Production_House p ON m.StudioID = p.StudioID
JOIN Content_Genre_Map cgm ON m.ContentID = cgm.ContentID
JOIN Genre_Lookup g ON cgm.GenreID = g.GenreID;
SET SQL_SAFE_UPDATES = 0;
UPDATE Media_Content 
SET Poster_URL = 'https://socialistmodernism.com/wp-content/uploads/2017/07/placeholder-image.png' 
WHERE Poster_URL IS NULL;
SET SQL_SAFE_UPDATES = 1;
USE Streampulse;
SET SQL_SAFE_UPDATES = 0;

-- 1. Marvel Studios (StudioID 4)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(51, 'Black Panther', 2018, 'Movie', 4, 'https://image.tmdb.org/t/p/w500/uxzzNc0Wle9vgo7S2A0UvR3m3ih.jpg'),
(52, 'Guardians of the Galaxy', 2014, 'Movie', 4, 'https://image.tmdb.org/t/p/w500/r7vmzYpS926GznY97Cj6vmgSTUr.jpg');

-- 2. A24 (StudioID 9)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(53, 'The Whale', 2022, 'Movie', 9, 'https://image.tmdb.org/t/p/w500/jQ064lsz9vfwvTbuvC9p79U669v.jpg'),
(54, 'Moonlight', 2016, 'Movie', 9, 'https://image.tmdb.org/t/p/w500/49Yv8U46SStp9887O9Y8Rof9C7p.jpg');

-- 3. Apple Studios (StudioID 14)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(55, 'CODA', 2021, 'Movie', 14, 'https://image.tmdb.org/t/p/w500/7uRbE0Go7f3Y6QAtv7p6pSNo68T.jpg'),
(56, 'Greyhound', 2020, 'Movie', 14, 'https://image.tmdb.org/t/p/w500/kjMB3TebGBS306S9S79X76vYv_b.jpg');

-- 4. 20th Century Studios (StudioID 2)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(57, 'Avatar: The Way of Water', 2022, 'Movie', 2, 'https://image.tmdb.org/t/p/w500/t6SnaI0YFA6pSjKrpnIgyLTrjYV.jpg'),
(58, 'Free Guy', 2021, 'Movie', 2, 'https://image.tmdb.org/t/p/w500/xmbU4SNaRRS7uSTjSjOQDEXMGws.jpg');

-- 5. Warner Bros. (StudioID 5)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(59, 'The Batman', 2022, 'Movie', 5, 'https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T6f4uC3.jpg'),
(60, 'Barbie', 2023, 'Movie', 5, 'https://image.tmdb.org/t/p/w500/iuFNmBTD0X4EXI0V9Qp3A6ukfS.jpg');

-- 6. Paramount Pictures (StudioID 6)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(61, 'Sonic the Hedgehog 2', 2022, 'Movie', 6, 'https://image.tmdb.org/t/p/w500/6DrHO1o3ABCUE60SXSTArDbADZq.jpg'),
(62, 'A Quiet Place', 2018, 'Movie', 6, 'https://image.tmdb.org/t/p/w500/nSbtv3Z6uGv4AqL97wsJ31cyU6p.jpg');

-- 7. Universal Pictures (StudioID 7)
INSERT INTO Media_Content (ContentID, Title, Release_Year, Content_Type, StudioID, Poster_URL) VALUES 
(63, 'The Super Mario Bros. Movie', 2023, 'Movie', 7, 'https://image.tmdb.org/t/p/w500/qNBAXBIQpSqc6YpZ7bR9S69W9m5.jpg'),
(64, 'Puss in Boots: The Last Wish', 2022, 'Movie', 7, 'https://image.tmdb.org/t/p/w500/kuf6Ykg7vSow46ee6o0S3HmcS5W.jpg');

-- CRITICAL: Map these new movies to genres so they show up in your Master_Catalog View
INSERT INTO Content_Genre_Map (ContentID, GenreID) VALUES 
(51, 32), (52, 1), (53, 8), (54, 8), (55, 8), (56, 22), (57, 18), (58, 5), (59, 1), (60, 5), (61, 2), (62, 13), (63, 3), (64, 3);

SET SQL_SAFE_UPDATES = 1;
CREATE OR REPLACE VIEW Master_Command_Center AS
SELECT 
    m.ContentID, m.Title, m.Release_Year, m.Content_Type, m.Poster_URL,
    p.Studio_Name,
    g.Genre_Name,
    cc.Legal_Name AS Lead_Actor,
    perf.Character_Role,
    sp.Name AS Streaming_Platform
FROM Media_Content m
LEFT JOIN Production_House p ON m.StudioID = p.StudioID
LEFT JOIN Content_Genre_Map cgm ON m.ContentID = cgm.ContentID
LEFT JOIN Genre_Lookup g ON cgm.GenreID = g.GenreID
LEFT JOIN Performance perf ON m.ContentID = perf.ContentID
LEFT JOIN Cast_Crew cc ON perf.PersonID = cc.PersonID
LEFT JOIN Content_Provider_Bridge cpb ON m.ContentID = cpb.ContentID
LEFT JOIN Streaming_Platforms sp ON cpb.PlatformID = sp.PlatformID;