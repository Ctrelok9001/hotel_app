CREATE TABLE room_types (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price NUMERIC(10, 2) NOT NULL CHECK (base_price > 0),
    capacity INT NOT NULL CHECK (capacity >= 1 AND capacity <= 10),
    amenities TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rooms (
    id VARCHAR(50) PRIMARY KEY,
    number VARCHAR(20) NOT NULL UNIQUE,
    floor INT NOT NULL CHECK (floor >= 1 AND floor <= 100),
    room_type_id VARCHAR(50) NOT NULL REFERENCES room_types(id) ON DELETE RESTRICT,
    status VARCHAR(30) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'cleaning', 'maintenance')),
    notes TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_rooms_type ON rooms(room_type_id);

CREATE TABLE guests (
    id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL,
    birth_date DATE,
    discount_percent NUMERIC(5, 2) NOT NULL DEFAULT 0.0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    notes TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_guests_phone ON guests(phone);
CREATE INDEX idx_guests_email ON guests(email);

CREATE TABLE passports (
    id VARCHAR(50) PRIMARY KEY,
    guest_id VARCHAR(50) NOT NULL UNIQUE REFERENCES guests(id) ON DELETE CASCADE,
    series VARCHAR(10) NOT NULL,
    number VARCHAR(10) NOT NULL,
    issued_by VARCHAR(255) NOT NULL,
    issue_date DATE,
    registration_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE services (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    description TEXT,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bookings (
    id VARCHAR(50) PRIMARY KEY,
    guest_id VARCHAR(50) NOT NULL REFERENCES guests(id) ON DELETE RESTRICT,
    room_id VARCHAR(50) NOT NULL REFERENCES rooms(id) ON DELETE RESTRICT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled')),
    total_price NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    discount_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    notes TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (check_out_date > check_in_date)
);

CREATE INDEX idx_bookings_dates ON bookings(check_in_date, check_out_date);
CREATE INDEX idx_bookings_room ON bookings(room_id);
CREATE INDEX idx_bookings_guest ON bookings(guest_id);
CREATE INDEX idx_bookings_status ON bookings(status);

CREATE TABLE booking_services (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50) NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    service_id VARCHAR(50) NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity >= 1),
    price_at_booking NUMERIC(10, 2) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_booking_services_bk ON booking_services(booking_id);

CREATE TABLE payments (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50) NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    guest_name VARCHAR(150),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('card', 'cash', 'sbp', 'transfer')),
    status VARCHAR(30) NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'pending', 'refunded')),
    transaction_code VARCHAR(50) NOT NULL UNIQUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_booking ON payments(booking_id);

CREATE TABLE employees (
    id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    position VARCHAR(50) NOT NULL CHECK (position IN ('manager', 'receptionist', 'maid', 'concierge')),
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL,
    shift VARCHAR(50) DEFAULT 'Дневная',
    salary NUMERIC(10, 2) NOT NULL CHECK (salary > 0),
    hire_date DATE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
    id VARCHAR(50) PRIMARY KEY,
    guest_id VARCHAR(50) NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    guest_name VARCHAR(150),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    response TEXT,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
