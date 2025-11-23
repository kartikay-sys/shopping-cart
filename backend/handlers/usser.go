package handlers

import (
	"math/rand"
	"time"

	"github.com/gin-gonic/gin"
	"shopping-cart-backend/db"
	"shopping-cart-backend/models"
)

func CreateUser(c *gin.Context) {
	var u models.User
	if err := c.BindJSON(&u); err != nil {
		c.JSON(400, gin.H{"error": "bad input"})
		return
	}
	db.DB.Create(&u)
	c.JSON(200, u)
}

func ListUsers(c *gin.Context) {
	var users []models.User
	db.DB.Find(&users)
	c.JSON(200, users)
}

func Login(c *gin.Context) {
	var body models.User
	if err := c.BindJSON(&body); err != nil {
		c.JSON(400, gin.H{"error": "bad input"})
		return
	}

	var u models.User
	db.DB.Where("username = ? AND password = ?", body.Username, body.Password).First(&u)
	if u.ID == 0 {
		c.JSON(401, gin.H{"error": "invalid"})
		return
	}

	rand.Seed(time.Now().UnixNano())
	token := fmt.Sprintf("%d-%d", u.ID, rand.Intn(999999))

	u.Token = token
	db.DB.Save(&u)

	c.JSON(200, gin.H{
		"token":   token,
		"user_id": u.ID,
	})
}
