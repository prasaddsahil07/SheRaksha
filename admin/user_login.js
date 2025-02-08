// Handle Show/Hide Password
document
  .getElementById("togglePassword")
  .addEventListener("click", function () {
    const passwordField = document.getElementById("password");
    const type = passwordField.type === "password" ? "text" : "password";
    passwordField.type = type;
    this.textContent = type === "password" ? "Show" : "Hide";
  });

// Validate Form Inputs
document.getElementById("loginForm").addEventListener("submit", function (e) {
  e.preventDefault();

  const emailField = document.getElementById("email");
  const passwordField = document.getElementById("password");
  const emailError = document.getElementById("emailError");
  const passwordError = document.getElementById("passwordError");

  let isValid = true;

  // Email Validation
  if (!emailField.value || !emailField.value.includes("@")) {
    emailError.textContent = "Please enter a valid email address.";
    emailError.style.display = "block";
    isValid = false;
  } else {
    emailError.style.display = "none";
  }

  // Password Validation
  if (!passwordField.value || passwordField.value.length < 6) {
    passwordError.textContent = "Password must be at least 6 characters long.";
    passwordError.style.display = "block";
    isValid = false;
  } else {
    passwordError.style.display = "none";
  }

  // Submit Form if Valid
  if (isValid) {
    alert("Login successful!");
    // Send request to the backend or redirect the user.
    // Example: window.location.href = 'dashboard.html';
  }
});
