package models

type Cart struct {
	ID     uint       `json:"id" gorm:"primaryKey"`
	UserID uint       `json:"user_id"`
	Items  []CartItem `json:"items"`
}

type CartItem struct {
	ID     uint `json:"id" gorm:"primaryKey"`
	CartID uint `json:"cart_id"`
	ItemID uint `json:"item_id"`
}
