package models

type Order struct {
	ID     uint `json:"id" gorm:"primaryKey"`
	UserID uint `json:"user_id"`
	CartID uint `json:"cart_id"`
}
