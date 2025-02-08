document.getElementById("password").addEventListener("input", function () {
  const strengthText = document.getElementById("passwordStrength");
  const password = this.value;
  const weakPattern = /.{6,}/;
  const strongPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

  if (strongPattern.test(password)) {
      strengthText.textContent = "Strength: Strong";
      strengthText.style.color = "green";
  } else if (weakPattern.test(password)) {
      strengthText.textContent = "Strength: Moderate";
      strengthText.style.color = "orange";
  } else {
      strengthText.textContent = "Strength: Weak";
      strengthText.style.color = "red";
  }
});
