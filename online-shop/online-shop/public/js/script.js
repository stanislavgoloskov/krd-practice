document.addEventListener('DOMContentLoaded', function() {
  // Валидация номера карты
  const cardNumberInput = document.getElementById('card_number');
  if (cardNumberInput) {
    cardNumberInput.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length > 16) {
        value = value.slice(0, 16);
      }
      e.target.value = value.replace(/(\d{4})(?=\d)/g, '$1 ');
    });
  }
  
  // Валидация месяца
  const expiryMonthInput = document.getElementById('expiry_month');
  if (expiryMonthInput) {
    expiryMonthInput.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length > 0) {
        const month = parseInt(value);
        if (month > 12) {
          value = '12';
        } else if (month < 1 && value.length === 2) {
          value = '01';
        }
      }
      if (value.length > 2) {
        value = value.slice(0, 2);
      }
      e.target.value = value;
    });
  }
  
  // Валидация года
  const expiryYearInput = document.getElementById('expiry_year');
  if (expiryYearInput) {
    expiryYearInput.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length > 2) {
        value = value.slice(0, 2);
      }
      e.target.value = value;
    });
  }
  
  // Валидация CVV
  const cvvInput = document.getElementById('cvv');
  if (cvvInput) {
    cvvInput.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length > 3) {
        value = value.slice(0, 3);
      }
      e.target.value = value;
    });
  }
});