import React, { useEffect, useState } from "react";

function App() {
  const [screen, setScreen] = useState("login");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const [token, setToken] = useState("");
  const [userId, setUserId] = useState(null);

  const [items, setItems] = useState([]);
  const [cartId, setCartId] = useState(null);

  const API = "http://localhost:8080";

  // when user returns with a saved token
  useEffect(() => {
    const t = localStorage.getItem("token");
    const u = localStorage.getItem("userId");
    if (t && u) {
      setToken(t);
      setUserId(parseInt(u));
      setScreen("items");
    }
  }, []);

  useEffect(() => {
    if (screen === "items" && token) {
      loadItems();
      loadCart();
    }
  }, [screen, token]);

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!username || !password) {
      window.alert("Please enter username/password");
      return;
    }

    try {
      const r = await fetch(API + "/users/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password })
      });

      if (!r.ok) {
        window.alert("Invalid username/password");
        return;
      }

      const data = await r.json();
      if (data && data.token) {
        setToken(data.token);
        setUserId(data.user_id);
        localStorage.setItem("token", data.token);
        localStorage.setItem("userId", data.user_id);
        setScreen("items");
      } else {
        window.alert("Invalid username/password");
      }
    } catch (err) {
      console.log("login err:", err);
      window.alert("Something went wrong");
    }
  };

  const loadItems = async () => {
    try {
      const r = await fetch(API + "/items");
      if (!r.ok) return;
      const d = await r.json();
      setItems(d || []);
    } catch (e) {
      console.log(e);
    }
  };

  const loadCart = async () => {
    try {
      const r = await fetch(API + "/carts", {
        headers: { Authorization: "Bearer " + token }
      });
      if (!r.ok) return;

      const d = await r.json();
      if (Array.isArray(d)) {
        let c = d.find((c) => c.user_id === userId);
        if (c) setCartId(c.id);
      }
    } catch (e) {
      console.log(e);
    }
  };

  const addToCart = async (itemId) => {
    if (!token) {
      window.alert("Login required");
      return;
    }

    try {
      const r = await fetch(API + "/carts", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: "Bearer " + token
        },
        body: JSON.stringify({ item_id: itemId })
      });

      if (!r.ok) {
        window.alert("Couldn't add item");
        return;
      }

      const d = await r.json();
      if (d && d.id) setCartId(d.id);

      window.alert("Item added to cart");
    } catch (e) {
      console.log(e);
      window.alert("Error adding item");
    }
  };

  const showCart = async () => {
    if (!token) return;

    try {
      const r = await fetch(API + "/carts", {
        headers: { Authorization: "Bearer " + token }
      });

      const d = await r.json();
      const mycart = d.find((c) => c.user_id === userId);

      if (!mycart || !mycart.items || mycart.items.length === 0) {
        window.alert("Cart empty");
        return;
      }

      let msg = "";
      mycart.items.forEach((x) => {
        msg += `cart_id=${x.cart_id}, item_id=${x.item_id}\n`;
      });

      window.alert(msg);
    } catch (e) {
      console.log(e);
    }
  };

  const showOrders = async () => {
    if (!token) return;

    try {
      const r = await fetch(API + "/orders", {
        headers: { Authorization: "Bearer " + token }
      });

      const d = await r.json();
      const myorders = d.filter((o) => o.user_id === userId);

      if (myorders.length === 0) {
        window.alert("No orders");
        return;
      }

      let msg = "";
      myorders.forEach((o) => (msg += `Order ID: ${o.id}\n`));
      window.alert(msg);
    } catch (e) {
      console.log(e);
    }
  };

  const checkout = async () => {
    if (!cartId) {
      window.alert("Cart empty");
      return;
    }

    try {
      const r = await fetch(API + "/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: "Bearer " + token
        },
        body: JSON.stringify({ cart_id: cartId })
      });

      if (!r.ok) {
        window.alert("Failed");
        return;
      }

      window.alert("Order successful");

      // reset cart
      setCartId(null);
      loadItems();
    } catch (e) {
      console.log(e);
    }
  };

  // UI SCREENS -----------------------------------------------------

  if (screen === "login") {
    return (
      <div style={{ padding: 30 }}>
        <h2>Login</h2>
        <form onSubmit={handleLogin}>
          <div>
            <input
              placeholder="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>
          <div style={{ marginTop: 10 }}>
            <input
              placeholder="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button style={{ marginTop: 15 }}>Login</button>
        </form>
      </div>
    );
  }

  return (
    <div style={{ padding: 30 }}>
      <div style={{ marginBottom: 20 }}>
        <button onClick={checkout}>Checkout</button>
        <button onClick={showCart} style={{ marginLeft: 10 }}>
          Cart
        </button>
        <button onClick={showOrders} style={{ marginLeft: 10 }}>
          Order History
        </button>
      </div>

      <h2>Items</h2>

      {items.length === 0 && <div>No items</div>}

      <ul>
        {items.map((it) => (
          <li
            key={it.id}
            onClick={() => addToCart(it.id)}
            style={{
              cursor: "pointer",
              padding: "8px 0",
              borderBottom: "1px solid #ddd",
              width: 200
            }}
          >
            {it.name}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
