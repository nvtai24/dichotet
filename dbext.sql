-- 1️⃣ Profiles (1-1 với auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY 
      REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role VARCHAR(50) DEFAULT 'user'
      CHECK (role IN ('user', 'admin'))
);

--------------------------------------------------

-- 2️⃣ Categories
CREATE TABLE categories (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL
);

--------------------------------------------------
-- 3️⃣ Shopping Items
CREATE TABLE shopping_items (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category_id INT 
      REFERENCES categories(id) ON DELETE SET NULL,
  quantity INT DEFAULT 1 CHECK (quantity > 0),
  unit VARCHAR(50),
  est_price_per_unit DECIMAL(10,2) CHECK (est_price_per_unit >= 0),
  note TEXT,
  user_id UUID NOT NULL
      REFERENCES auth.users(id) ON DELETE CASCADE,
  is_purchased BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_shopping_items_user_id 
ON shopping_items(user_id);

--------------------------------------------------

-- 4️⃣ Purchase Locations
CREATE TABLE purchase_locations (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  shopping_item_id INT NOT NULL
      REFERENCES shopping_items(id) ON DELETE CASCADE,
  location_name TEXT NOT NULL,
  lat DECIMAL(10,8),
  lon DECIMAL(11,8),
  price_per_unit DECIMAL(10,2) CHECK (price_per_unit >= 0)
);

--------------------------------------------------

-- 5️⃣ Purchases (nếu cần lưu lịch sử)
CREATE TABLE purchases (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  shopping_item_id INT NOT NULL
      REFERENCES shopping_items(id) ON DELETE CASCADE,
  purchase_location_id INT
      REFERENCES purchase_locations(id) ON DELETE SET NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  price_per_unit DECIMAL(10,2) CHECK (price_per_unit >= 0),
  purchased_at TIMESTAMP DEFAULT NOW()
);