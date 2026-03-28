-- ================= DATABASE =================
CREATE DATABASE IF NOT EXISTS bus_booking;
USE bus_booking;

-- ================= USERS TABLE =================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================= BUSES TABLE =================
CREATE TABLE IF NOT EXISTS buses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bus_name VARCHAR(100) NOT NULL,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    stops JSON, -- Array of stop names in order
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    travel_date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    seats_total INT NOT NULL DEFAULT 40,
    bus_type ENUM('AC', 'Non-AC', 'Sleeper', 'Seater', 'Double Decker') DEFAULT 'Non-AC',
    amenities JSON, -- Array of amenities like ['WiFi', 'Charging', 'Water']
    rating DECIMAL(3,2) DEFAULT 4.5,
    operator VARCHAR(100) DEFAULT 'BusHub'
);

-- ================= ROUTES TABLE (for multiple stops) =================
CREATE TABLE IF NOT EXISTS routes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT NOT NULL,
    stop_name VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL,
    arrival_time TIME,
    departure_time TIME,
    FOREIGN KEY (bus_id) REFERENCES buses(id) ON DELETE CASCADE
);

-- ================= BOOKINGS TABLE =================


-- ================= SEAT DETAILS TABLE =================
CREATE TABLE IF NOT EXISTS seat_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_type ENUM('Window', 'Aisle', 'Sleeper', 'Seater') DEFAULT 'Seater',
    deck ENUM('Lower', 'Upper') DEFAULT 'Lower',
    gender_restriction ENUM('Male', 'Female', 'None') DEFAULT 'None',
    price_modifier DECIMAL(3,2) DEFAULT 1.0, -- Multiplier for seat price
    FOREIGN KEY (bus_id) REFERENCES buses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_bus_seat (bus_id, seat_number)
);

-- ================= ADMIN USERS =================
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================= CLEAR OLD DATA =================
DELETE FROM routes;
DELETE FROM seat_details;
DELETE FROM bookings;
DELETE FROM buses;
DELETE FROM users;

-- ================= INSERT ADMIN USER =================
INSERT INTO admin_users (username, password, email) VALUES
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeCt1uB0YgLpBqLZS', 'admin@bushub.com'); -- password: admin123

-- ================= INSERT SAMPLE BUSES =================
INSERT INTO buses (bus_name, source, destination, stops, departure_time, arrival_time, travel_date, price, seats_total, bus_type, amenities, rating, operator) VALUES
('KSRTC Express', 'Kochi', 'Coimbatore', '["Kochi", "Thrissur", "Palakkad", "Coimbatore"]', '08:00:00', '16:00:00', '2026-03-22', 1200.00, 40, 'AC', '["WiFi", "Charging", "Water", "Blanket"]', 4.2, 'KSRTC'),
('Super Deluxe', 'Calicut', 'Trivandrum', '["Calicut", "Kannur", "Kochi", "Trivandrum"]', '09:00:00', '20:00:00', '2026-03-22', 1500.00, 45, 'Sleeper', '["WiFi", "AC", "Water"]', 4.5, 'Private'),
('TNSTC Express', 'Chennai', 'Coimbatore', '["Chennai", "Vellore", "Salem", "Coimbatore"]', '06:00:00', '14:00:00', '2026-03-22', 1000.00, 40, 'Non-AC', '["Water"]', 3.8, 'TNSTC'),
('Volvo AC', 'Bangalore', 'Chennai', '["Bangalore", "Hosur", "Krishnagiri", "Chennai"]', '22:00:00', '06:00:00', '2026-03-22', 1800.00, 40, 'AC', '["WiFi", "Charging", "Water", "Entertainment"]', 4.7, 'Volvo'),
('Shivneri', 'Mumbai', 'Pune', '["Mumbai", "Thane", "Pune"]', '07:00:00', '10:00:00', '2026-03-22', 600.00, 50, 'AC', '["WiFi", "Water"]', 4.0, 'MSRTC'),
-- Additional routes and buses
('AirBus Premium', 'Bangalore', 'Hyderabad', '["Bangalore", "Kolar", "Chikballapur", "Hyderabad"]', '10:00:00', '18:00:00', '2026-03-22', 1100.00, 45, 'AC', '["WiFi", "Charging", "Water", "Pillow"]', 4.6, 'AirBus'),
('SafeJourney Express', 'Hyderabad', 'Bangalore', '["Hyderabad", "Kurnool City", "Chikballapur", "Bangalore"]', '17:00:00', '01:00:00', '2026-03-22', 950.00, 40, 'AC', '["WiFi", "AC"]', 4.3, 'SafeJourney'),
('Night Rider Sleeper', 'Trivandrum', 'Bangalore', '["Trivandrum", "Kochi", "Coimbatore", "Bangalore"]', '20:00:00', '10:00:00', '2026-03-22', 2000.00, 32, 'Sleeper', '["WiFi", "Charging", "Water", "Meals"]', 4.8, 'Night Rider'),
('City Link AC', 'Mumbai', 'Delhi', '["Mumbai", "Indore", "Bhopal", "Agra", "Delhi"]', '14:00:00', '08:00:00', '2026-03-22', 2200.00, 48, 'AC', '["WiFi", "Charging", "Water", "Entertainment", "Snacks"]', 4.5, 'City Link'),
('Budget Travels', 'Pune', 'Goa', '["Pune", "Lonavala", "Belgaum", "Goa"]', '15:00:00', '22:00:00', '2026-03-22', 550.00, 50, 'Non-AC', '["Water"]', 3.6, 'Budget Travels'),
('Deluxe Express', 'Goa', 'Pune', '["Goa", "Belgaum", "Lonavala", "Pune"]', '08:00:00', '15:00:00', '2026-03-22', 700.00, 40, 'AC', '["WiFi", "Water"]', 4.2, 'Deluxe Express'),
('Comfort Plus', 'Chennai', 'Bangalore', '["Chennai", "Chikballapur", "Bangalore"]', '13:30:00', '20:00:00', '2026-03-22', 1400.00, 45, 'AC', '["WiFi", "Charging", "Water", "Snacks"]', 4.4, 'Comfort Plus'),
('Swift Journey', 'Bangalore', 'Chennai', '["Bangalore", "Kolar", "Chikballapur", "Chennai"]', '11:00:00', '17:30:00', '2026-03-22', 900.00, 40, 'Non-AC', '["Water", "AC"]', 3.9, 'Swift Journey'),
('Royal Coach', 'Kochi', 'Bangalore', '["Kochi", "Thrissur", "Palakkad", "Coimbatore", "Bangalore"]', '18:00:00', '08:00:00', '2026-03-22', 1600.00, 38, 'Sleeper', '["WiFi", "Charging", "Water", "Blanket", "Pillow"]', 4.7, 'Royal Coach'),
('Express Plus', 'Calicut', 'Bangalore', '["Calicut", "Kannur", "Kochi", "Coimbatore", "Bangalore"]', '19:00:00', '10:00:00', '2026-03-22', 1750.00, 42, 'AC', '["WiFi", "Charging", "Water"]', 4.3, 'Express Plus'),
('Morning Glory', 'Delhi', 'Jaipur', '["Delhi", "Noida", "Agra", "Jaipur"]', '06:30:00', '12:00:00', '2026-03-22', 800.00, 40, 'AC', '["WiFi", "Water"]', 4.1, 'Morning Glory'),
('Night Express', 'Jaipur', 'Delhi', '["Jaipur", "Agra", "Noida", "Delhi"]', '21:00:00', '02:30:00', '2026-03-22', 650.00, 45, 'Non-AC', '["Water"]', 3.7, 'Night Express'),
('Premium Sleeper', 'Lucknow', 'Delhi', '["Lucknow", "Agra", "Delhi"]', '20:00:00', '06:00:00', '2026-03-22', 1300.00, 36, 'Sleeper', '["WiFi", "Charging", "Water", "Meals", "Blanket"]', 4.6, 'Premium Sleeper'),
('Quick Ride', 'Bangalore', 'Mysore', '["Bangalore", "Ramanagaram", "Mysore"]', '09:00:00', '13:00:00', '2026-03-22', 450.00, 40, 'Non-AC', '["Water"]', 3.8, 'Quick Ride'),
('Mysore Express', 'Mysore', 'Bangalore', '["Mysore", "Ramanagaram", "Bangalore"]', '16:00:00', '20:00:00', '2026-03-22', 500.00, 40, 'AC', '["WiFi", "Water"]', 4.0, 'Mysore Express'),
('Kerala Express', 'Trivandrum', 'Calicut', '["Trivandrum", "Kochi", "Kannur", "Calicut"]', '07:00:00', '14:00:00', '2026-03-22', 1050.00, 43, 'AC', '["WiFi", "Water", "AC"]', 4.2, 'Kerala Express'),
('Coastal Link', 'Calicut', 'Trivandrum', '["Calicut", "Kannur", "Kochi", "Aymanam", "Trivandrum"]', '17:00:00', '23:30:00', '2026-03-22', 1100.00, 40, 'AC', '["WiFi", "Charging", "Water"]', 4.4, 'Coastal Link');

-- ================= INSERT ROUTES =================
INSERT INTO routes (bus_id, stop_name, stop_order, arrival_time, departure_time) VALUES
-- Bus 1: Kochi -> Coimbatore
(1, 'Kochi', 1, NULL, '08:00:00'),
(1, 'Thrissur', 2, '10:00:00', '10:15:00'),
(1, 'Palakkad', 3, '12:00:00', '12:15:00'),
(1, 'Coimbatore', 4, '16:00:00', NULL),

-- Bus 2: Calicut -> Trivandrum
(2, 'Calicut', 1, NULL, '09:00:00'),
(2, 'Kannur', 2, '11:00:00', '11:15:00'),
(2, 'Kochi', 3, '14:00:00', '14:30:00'),
(2, 'Trivandrum', 4, '20:00:00', NULL),

-- Bus 3: Chennai -> Coimbatore
(3, 'Chennai', 1, NULL, '06:00:00'),
(3, 'Vellore', 2, '08:00:00', '08:15:00'),
(3, 'Salem', 3, '11:00:00', '11:15:00'),
(3, 'Coimbatore', 4, '14:00:00', NULL),

-- Bus 4: Bangalore -> Chennai
(4, 'Bangalore', 1, NULL, '22:00:00'),
(4, 'Hosur', 2, '23:30:00', '23:45:00'),
(4, 'Krishnagiri', 3, '01:00:00', '01:15:00'),
(4, 'Chennai', 4, '06:00:00', NULL),

-- Bus 5: Mumbai -> Pune
(5, 'Mumbai', 1, NULL, '07:00:00'),
(5, 'Thane', 2, '08:00:00', '08:15:00'),
(5, 'Pune', 3, '10:00:00', NULL),

-- Bus 6: Bangalore -> Hyderabad
(6, 'Bangalore', 1, NULL, '10:00:00'),
(6, 'Kolar', 2, '12:00:00', '12:15:00'),
(6, 'Chikballapur', 3, '14:00:00', '14:15:00'),
(6, 'Hyderabad', 4, '18:00:00', NULL),

-- Bus 7: Hyderabad -> Bangalore
(7, 'Hyderabad', 1, NULL, '17:00:00'),
(7, 'Kurnool City', 2, '20:00:00', '20:15:00'),
(7, 'Chikballapur', 3, '23:00:00', '23:15:00'),
(7, 'Bangalore', 4, '01:00:00', NULL),

-- Bus 8: Trivandrum -> Bangalore
(8, 'Trivandrum', 1, NULL, '20:00:00'),
(8, 'Kochi', 2, '23:00:00', '23:30:00'),
(8, 'Coimbatore', 3, '03:00:00', '03:30:00'),
(8, 'Bangalore', 4, '10:00:00', NULL),

-- Bus 9: Mumbai -> Delhi
(9, 'Mumbai', 1, NULL, '14:00:00'),
(9, 'Indore', 2, '19:00:00', '19:30:00'),
(9, 'Bhopal', 3, '23:00:00', '23:30:00'),
(9, 'Agra', 4, '04:00:00', '04:30:00'),
(9, 'Delhi', 5, '08:00:00', NULL),

-- Bus 10: Pune -> Goa
(10, 'Pune', 1, NULL, '15:00:00'),
(10, 'Lonavala', 2, '17:00:00', '17:15:00'),
(10, 'Belgaum', 3, '20:00:00', '20:15:00'),
(10, 'Goa', 4, '22:00:00', NULL),

-- Bus 11: Goa -> Pune
(11, 'Goa', 1, NULL, '08:00:00'),
(11, 'Belgaum', 2, '10:00:00', '10:15:00'),
(11, 'Lonavala', 3, '13:00:00', '13:15:00'),
(11, 'Pune', 4, '15:00:00', NULL),

-- Bus 12: Chennai -> Bangalore
(12, 'Chennai', 1, NULL, '13:30:00'),
(12, 'Kolar', 2, '17:00:00', '17:15:00'),
(12, 'Chikballapur', 3, '18:30:00', '18:45:00'),
(12, 'Bangalore', 4, '20:00:00', NULL),

-- Bus 13: Bangalore -> Chennai
(13, 'Bangalore', 1, NULL, '11:00:00'),
(13, 'Kolar', 2, '13:00:00', '13:15:00'),
(13, 'Chikballapur', 3, '14:30:00', '14:45:00'),
(13, 'Chennai', 4, '17:30:00', NULL),

-- Bus 14: Kochi -> Bangalore
(14, 'Kochi', 1, NULL, '18:00:00'),
(14, 'Thrissur', 2, '20:00:00', '20:15:00'),
(14, 'Palakkad', 3, '22:00:00', '22:30:00'),
(14, 'Coimbatore', 4, '01:00:00', '01:30:00'),
(14, 'Bangalore', 5, '08:00:00', NULL),

-- Bus 15: Calicut -> Bangalore
(15, 'Calicut', 1, NULL, '19:00:00'),
(15, 'Kannur', 2, '21:00:00', '21:15:00'),
(15, 'Kochi', 3, '23:30:00', '00:15:00'),
(15, 'Coimbatore', 4, '04:00:00', '04:30:00'),
(15, 'Bangalore', 5, '10:00:00', NULL),

-- Bus 16: Delhi -> Jaipur
(16, 'Delhi', 1, NULL, '06:30:00'),
(16, 'Noida', 2, '07:30:00', '07:45:00'),
(16, 'Agra', 3, '10:00:00', '10:15:00'),
(16, 'Jaipur', 4, '12:00:00', NULL),

-- Bus 17: Jaipur -> Delhi
(17, 'Jaipur', 1, NULL, '21:00:00'),
(17, 'Agra', 2, '23:00:00', '23:15:00'),
(17, 'Noida', 3, '01:30:00', '01:45:00'),
(17, 'Delhi', 4, '02:30:00', NULL),

-- Bus 18: Lucknow -> Delhi
(18, 'Lucknow', 1, NULL, '20:00:00'),
(18, 'Agra', 2, '02:00:00', '02:30:00'),
(18, 'Delhi', 3, '06:00:00', NULL),

-- Bus 19: Bangalore -> Mysore
(19, 'Bangalore', 1, NULL, '09:00:00'),
(19, 'Ramanagaram', 2, '11:00:00', '11:15:00'),
(19, 'Mysore', 3, '13:00:00', NULL),

-- Bus 20: Mysore -> Bangalore
(20, 'Mysore', 1, NULL, '16:00:00'),
(20, 'Ramanagaram', 2, '18:00:00', '18:15:00'),
(20, 'Bangalore', 3, '20:00:00', NULL),

-- Bus 21: Trivandrum -> Calicut
(21, 'Trivandrum', 1, NULL, '07:00:00'),
(21, 'Kochi', 2, '10:00:00', '10:30:00'),
(21, 'Kannur', 3, '12:00:00', '12:15:00'),
(21, 'Calicut', 4, '14:00:00', NULL),

-- Bus 22: Calicut -> Trivandrum
(22, 'Calicut', 1, NULL, '17:00:00'),
(22, 'Kannur', 2, '19:00:00', '19:15:00'),
(22, 'Kochi', 3, '21:00:00', '21:30:00'),
(22, 'Aymanam', 4, '23:00:00', '23:15:00'),
(22, 'Trivandrum', 5, '23:30:00', NULL);

-- ================= INSERT SEAT DETAILS =================
-- For simplicity, insert seats for bus 1 (40 seats)
INSERT INTO seat_details (bus_id, seat_number, seat_type, deck, gender_restriction, price_modifier) VALUES
(1, '1A', 'Window', 'Lower', 'None', 1.0),
(1, '1B', 'Aisle', 'Lower', 'None', 1.0),
(1, '2A', 'Window', 'Lower', 'None', 1.0),
(1, '2B', 'Aisle', 'Lower', 'None', 1.0),
(1, '3A', 'Window', 'Lower', 'None', 1.0),
(1, '3B', 'Aisle', 'Lower', 'None', 1.0),
(1, '4A', 'Window', 'Lower', 'None', 1.0),
(1, '4B', 'Aisle', 'Lower', 'None', 1.0),
(1, '5A', 'Window', 'Lower', 'None', 1.0),
(1, '5B', 'Aisle', 'Lower', 'None', 1.0),
(1, '6A', 'Window', 'Lower', 'None', 1.0),
(1, '6B', 'Aisle', 'Lower', 'None', 1.0),
(1, '7A', 'Window', 'Lower', 'None', 1.0),
(1, '7B', 'Aisle', 'Lower', 'None', 1.0),
(1, '8A', 'Window', 'Lower', 'None', 1.0),
(1, '8B', 'Aisle', 'Lower', 'None', 1.0),
(1, '9A', 'Window', 'Lower', 'None', 1.0),
(1, '9B', 'Aisle', 'Lower', 'None', 1.0),
(1, '10A', 'Window', 'Lower', 'None', 1.0),
(1, '10B', 'Aisle', 'Lower', 'None', 1.0),
(1, '11A', 'Window', 'Upper', 'None', 1.1),
(1, '11B', 'Aisle', 'Upper', 'None', 1.1),
(1, '12A', 'Window', 'Upper', 'None', 1.1),
(1, '12B', 'Aisle', 'Upper', 'None', 1.1),
(1, '13A', 'Window', 'Upper', 'None', 1.1),
(1, '13B', 'Aisle', 'Upper', 'None', 1.1),
(1, '14A', 'Window', 'Upper', 'None', 1.1),
(1, '14B', 'Aisle', 'Upper', 'None', 1.1),
(1, '15A', 'Window', 'Upper', 'None', 1.1),
(1, '15B', 'Aisle', 'Upper', 'None', 1.1),
(1, '16A', 'Window', 'Upper', 'None', 1.1),
(1, '16B', 'Aisle', 'Upper', 'None', 1.1),
(1, '17A', 'Window', 'Upper', 'None', 1.1),
(1, '17B', 'Aisle', 'Upper', 'None', 1.1),
(1, '18A', 'Window', 'Upper', 'None', 1.1),
(1, '18B', 'Aisle', 'Upper', 'None', 1.1),
(1, '19A', 'Window', 'Upper', 'None', 1.1),
(1, '19B', 'Aisle', 'Upper', 'None', 1.1),
(1, '20A', 'Window', 'Upper', 'None', 1.1),
(1, '20B', 'Aisle', 'Upper', 'None', 1.1);CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    bus_id INT NOT NULL,
    seats JSON NOT NULL, -- Array of seat objects with details
    emergency_services JSON NULL, -- Optional emergency medical items requested
    passenger_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15),
    email VARCHAR(100),
    boarding_point VARCHAR(100) NOT NULL,
    dropping_point VARCHAR(100) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    travel_date DATE,
    booking_id VARCHAR(20) UNIQUE,
    status ENUM('confirmed', 'cancelled') DEFAULT 'confirmed',
    refund_amount DECIMAL(10,2) DEFAULT 0,
    cancelled_at TIMESTAMP NULL,
    payment_method ENUM('UPI', 'Credit/Debit Card', 'Net Banking') NOT NULL,
    payment_reference_id VARCHAR(100) NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (bus_id) REFERENCES buses(id),
    CONSTRAINT check_amount CHECK (total_amount > 0),
    INDEX idx_user_id (user_id),
    INDEX idx_bus_id (bus_id),
    INDEX idx_booking_date (booking_date)
);

-- ================= SITE RATINGS TABLE =================
CREATE TABLE IF NOT EXISTS site_ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_user_rating (user_id)
);

-- ================= INSERT SAMPLE SITE RATINGS =================
INSERT INTO site_ratings (user_id, rating, review) VALUES
(1, 5, 'Excellent service! Very easy to book buses and the interface is user-friendly.'),
(2, 4, 'Great platform for bus booking. Would love to see more payment options.'),
(3, 5, 'Amazing experience! Fast booking process and reliable service.');