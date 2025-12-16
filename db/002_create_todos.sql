CREATE TABLE IF NOT EXISTS todos (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  title VARCHAR(255),
  description TEXT,
  status VARCHAR(50),
  due_date VARCHAR(50),
  created_at DATETIME,
  updated_at DATETIME
);
