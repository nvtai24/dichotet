-- EXTENSION (Supabase thường đã có)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

--------------------------------------------------
-- 1️⃣ Profiles (1-1 với auth.users)

CREATE TABLE profiles (
  id UUID PRIMARY KEY
      REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role VARCHAR(50) DEFAULT 'user'
      CHECK (role IN ('user', 'admin')),
  phone VARCHAR(20)
);

--------------------------------------------------
-- 2️⃣ Categories

CREATE TABLE categories (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL
);

--------------------------------------------------
-- 3️⃣ Shopping Sessions (Tết 2025, Tết 2026,...)

CREATE TABLE shopping_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL
      REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sessions_user
ON shopping_sessions(user_id);

--------------------------------------------------
-- 4️⃣ Shopping Items

CREATE TABLE shopping_items (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

  session_id UUID NOT NULL
      REFERENCES shopping_sessions(id) ON DELETE CASCADE,

  name VARCHAR(255) NOT NULL,

  category_id INT
      REFERENCES categories(id) ON DELETE SET NULL,

  quantity INT DEFAULT 1
      CHECK (quantity > 0),

  unit VARCHAR(50),

  est_price_per_unit DECIMAL(10,2)
      CHECK (est_price_per_unit >= 0),

  note TEXT,

  user_id UUID NOT NULL
      REFERENCES auth.users(id) ON DELETE CASCADE,

  is_purchased BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_shopping_items_user
ON shopping_items(user_id);

CREATE INDEX idx_shopping_items_session
ON shopping_items(session_id);

--------------------------------------------------
-- 5️⃣ Purchase Locations

CREATE TABLE purchase_locations (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

  shopping_item_id INT NOT NULL
      REFERENCES shopping_items(id) ON DELETE CASCADE,

  location_name TEXT NOT NULL,

  lat DECIMAL(10,8),
  lon DECIMAL(11,8),

  price_per_unit DECIMAL(10,2)
      CHECK (price_per_unit >= 0)
);

--------------------------------------------------
-- 6️⃣ Purchases (lưu lịch sử mua)

CREATE TABLE purchases (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

  shopping_item_id INT NOT NULL
      REFERENCES shopping_items(id) ON DELETE CASCADE,

  purchase_location_id INT
      REFERENCES purchase_locations(id) ON DELETE SET NULL,

  quantity INT NOT NULL
      CHECK (quantity > 0),

  price_per_unit DECIMAL(10,2)
      CHECK (price_per_unit >= 0),

  purchased_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_purchases_item
ON purchases(shopping_item_id);