package handlers

import (
	"github.com/gin-gonic/gin"
	"shopping-cart-backend/db"
	"shopping-cart-backend/models"
)

func CreateItem(c *gin.Context) {
	var it models.Item
	if err := c.BindJSON(&it); err != nil {
		c.JSON(400, gin.H{"error": "bad input"})
		return
	}
	db.DB.Create(&it)
	c.JSON(200, it)
}

func ListItems(c *gin.Context) {
	var items []models.Item
	db.DB.Find(&items)
	c.JSON(200, items)
}
