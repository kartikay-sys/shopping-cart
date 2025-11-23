import React, { useEffect, useState } from "react";

function App() {
  const [screen, setScreen] = useState("login");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const [token, setToken] = useState("");
  const [userId, setUserId] = useState(null);

  const [items, setItems] = useState([]);
  const [cartId, setCartId] = useState(null);

  // Change this to your backend URL after hosting
  const API = "http://localhost:8080";

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!username || !password) {
      window.alert("Invalid username/password");
      return;
    }

    try {
      const res = await fetch(API + "/users/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password })
      });

      if (!res.ok) {
        window.alert("Invalid username/password");
        return;
      }

      const data = await res.json();
      setToken(data.token);
      setUserId(data.user_id);

      setScreen("items");
      loadItems(data.token);
      loadCart(data.token, data.user_id);
    } catch (err) {
      console.log(err);
      window.alert("Invalid username/password");
    }
  };

  const loadItems = async (t = token) => {
    try {
      const r = await fetch(API + "/items");
      const d = await r.json();
      setItems(d || []);
    } catch {}
  };

  const loadCart = async (t = token, uid = userId) => {
    try {
      const r = await fetch(API + "/carts", {
        headers: { Authorization: "Bearer " + t }
      });
      const data = await r.json();

      const mine = data.find((c) => c.user_id === uid);
      if (mine) setCartId(mine.id);
    } catch {}
  };

  const addToCart = async (itemId) => {
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
        window.alert("Failed to add item");
        return;
      }

      const data = await r.json();
      setCartId(data.id);
      window.alert("Item added");
    } catch (err) {
      console.log(err);
    }
  };

  const showCart = async () => {
    try {
      const r = await fetch(API + "/carts", {
        headers: { Authorization: "Bearer " + token }
      });

      const data = await r.json();
      const mine = data.find((c) => c.user_id === userId);

      if (!mine || !mine.items || mine.items.length === 0) {
        window.alert("Cart is empty");
        return;
      }

      let msg = "";
      mine.items.forEach((i) => {
        msg += `cart_id=${i.cart_id}, item_id=${i.item_id}\n`;
      });

      window.alert(msg);
    } catch {}
  };

  const showOrders = async () => {
    try {
      const r = await fetch(API + "/orders", {
        headers: { Authorization: "Bearer " + token }
      });

      const data = await r.json();
      const myOrders = data.filter((o) => o.user_id === userId);

      if (myOrders.length === 0) {
        window.alert("No orders placed");
        return;
      }

      let msg = "";
      myOrders.forEach((o) => (msg += `Order ID: ${o.id}\n`));
      window.alert(msg);
    } catch {}
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
        window.alert("Failed to checkout");
        return;
      }

      window.alert("Order successful");
      loadItems();
      loadCart();
    } catch {}
  };

  if (screen === "login") {
    return (
      <div style={{ padding: 30 }}>
        <h2>Login</h2>
        <form onSubmit={handleLogin}>
          <input
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          <br />
          <input
            placeholder="Password"
            type="password"
            style={{ marginTop: 10 }}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <br />
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

      <ul>
        {items.map((it) => (
          <li
            key={it.id}
            onClick={() => addToCart(it.id)}
            style={{ cursor: "pointer", borderBottom: "1px solid #ddd", width: 200, padding: "5px 0" }}
          >
            {it.name}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
