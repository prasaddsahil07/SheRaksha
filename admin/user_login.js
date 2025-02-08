document.addEventListener("DOMContentLoaded", function () {
  const loginForm = document.getElementById("loginForm");
  const togglePassword = document.getElementById("togglePassword");

  // Show/hide password functionality
  togglePassword.addEventListener("click", function () {
    const passwordInput = document.getElementById("password");
    if (passwordInput.type === "password") {
      passwordInput.type = "text";
      togglePassword.textContent = "Hide";
    } else {
      passwordInput.type = "password";
      togglePassword.textContent = "Show";
    }
  });

  // Handle form submission
  loginForm.addEventListener("submit", async function (event) {
    event.preventDefault(); // Prevent form from refreshing the page

    // Get user input values
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value.trim();
    const emailError = document.getElementById("emailError");
    const passwordError = document.getElementById("passwordError");

    // Clear previous errors
    emailError.textContent = "";
    passwordError.textContent = "";

    // Basic validation
    if (!email.includes("@")) {
      emailError.textContent = "Enter a valid email.";
      return;
    }
    if (password.length < 6) {
      passwordError.textContent = "Password must be at least 6 characters.";
      return;
    }

    try {
      const response = await fetch("http://localhost:5000/api/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
        credentials: "include" // ✅ Sends cookies for authentication
      });

      const data = await response.json();

      if (response.ok) {
        // ✅ Save user session (optional, if token-based auth)
        localStorage.setItem("user", JSON.stringify(data.user));

        // ✅ Redirect to `index.html`
        window.location.href = "index.html";
      } else {
        // Show error messages from the backend
        if (data.message) {
          alert(data.message);
        }
      }
    } catch (error) {
      console.error("Login error:", error);
      alert("Something went wrong. Try again later.");
    }
  });
});
