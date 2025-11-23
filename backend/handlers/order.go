package handlers

import (
	"github.com/gin-gonic/gin"
	"shopping-cart-backend/db"
	"shopping-cart-backend/models"
)

func CreateOrder(c *gin.Context) {
	token := c.GetHeader("Authorization")
	user := getUserFromToken(token)
	if user.ID == 0 {
		c.JSON(401, gin.H{"error": "invalid"})
		return
	}

	var body struct {
		CartID uint `json:"cart_id"`
	}
	c.BindJSON(&body)

	order := models.Order{
		UserID: user.ID,
		CartID: body.CartID,
	}

	db.DB.Create(&order)
	c.JSON(200, order)
}

func ListOrders(c *gin.Context) {
	var orders []models.Order
	db.DB.Find(&orders)
	c.JSON(200, orders)
}
