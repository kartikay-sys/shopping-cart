package main

import (
	"github.com/gin-gonic/gin"
	"shopping-cart-backend/db"
	"shopping-cart-backend/handlers"
)

func main() {
	db.Connect()

	r := gin.Default()

	r.POST("/users", handlers.CreateUser)
	r.GET("/users", handlers.ListUsers)
	r.POST("/users/login", handlers.Login)

	r.POST("/items", handlers.CreateItem)
	r.GET("/items", handlers.ListItems)

	r.POST("/carts", handlers.AddToCart)
	r.GET("/carts", handlers.ListCarts)

	r.POST("/orders", handlers.CreateOrder)
	r.GET("/orders", handlers.ListOrders)

	r.Run(":8080")
}
