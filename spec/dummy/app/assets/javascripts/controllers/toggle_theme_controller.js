
class ToggleTheme {
  static init() {
    const theme = this.getTheme() || 'light';
    this.setTheme(theme);
  }

  static setTheme(theme) {
    $('html').attr('data-bs-theme', theme)
    localStorage.setItem('theme', theme)
    this.setBtnTheme(theme)
  }

  static getTheme() {
    return localStorage.getItem('theme')
  }

  static currentTheme() {
    this.getTheme() === 'dark' ? this.iconDark() : this.iconLight();
  }

  static setBtnTheme(theme) {
    $('#bd-theme').html(theme === 'dark' ? this.iconDark() : this.iconLight())
  }

  static iconDark() {
    return '<i class="bi bi-moon-fill"></i>';
  }

  static iconLight() {
    return '<i class="bi bi-sun-fill"></i>';
  }
}

(function () {
  this.App || (this.App = {});

  this.App.ToggleTheme = ToggleTheme
}).call(this);
