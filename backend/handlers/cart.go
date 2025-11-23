package handlers

import (
	"github.com/gin-gonic/gin"
	"shopping-cart-backend/db"
	"shopping-cart-backend/models"
)

func getUserFromToken(t string) models.User {
	var u models.User
	db.DB.Where("token = ?", t).First(&u)
	return u
}

func AddToCart(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.JSON(401, gin.H{"error": "no token"})
		return
	}

	var user = getUserFromToken(token)
	if user.ID == 0 {
		c.JSON(401, gin.H{"error": "invalid token"})
		return
	}

	var body struct {
		ItemID uint `json:"item_id"`
	}
	if c.BindJSON(&body) != nil {
		c.JSON(400, gin.H{"error": "bad input"})
		return
	}

	var cart models.Cart
	db.DB.Where("user_id = ?", user.ID).First(&cart)
	if cart.ID == 0 {
		cart.UserID = user.ID
		db.DB.Create(&cart)
	}

	ci := models.CartItem{CartID: cart.ID, ItemID: body.ItemID}
	db.DB.Create(&ci)

	db.DB.Preload("Items").First(&cart, cart.ID)
	c.JSON(200, cart)
}

func ListCarts(c *gin.Context) {
	var carts []models.Cart
	db.DB.Preload("Items").Find(&carts)
	c.JSON(200, carts)
}
