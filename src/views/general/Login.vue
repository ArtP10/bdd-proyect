<template>
  <div class="login-container">
    <div class="login-card">
      <h2 class="title">Iniciar sesión en Viajes Ucab</h2>

      <form @submit.prevent="handleLogin">
        
        <div class="role-group">
          <label class="role-label">Ingresar como:</label>
          <div class="radio-options">
            <label class="radio-item">
              <input 
                type="radio" 
                name="role" 
                value="cliente" 
                v-model="form.user_type"
              >
              <span>Cliente</span>
            </label>
            <label class="radio-item">
              <input 
                type="radio" 
                name="role" 
                value="proveedor" 
                v-model="form.user_type"
              >
              <span>Proveedor</span>
            </label>
            <label class="radio-item">
              <input 
                type="radio" 
                name="role" 
                value="administrador" 
                v-model="form.user_type"
              >
              <span>Admin</span>
            </label>
          </div>
        </div>

        <div class="form-group">
          <label for="username">Usuario</label>
          <input 
            id="username" 
            type="text" 
            v-model="form.user_name" 
            placeholder="tuNombre" 
            required
          />
        </div>

        <div class="form-group">
          <label for="password">Contraseña</label>
          <input 
            id="password" 
            type="password" 
            v-model="form.user_password" 
            placeholder="••••••••" 
            required
          />
        </div>

        
        <div class="button-group">
          <button type="submit" class="btn btn-primary" :disabled="isLoading">
            {{ isLoading ? 'Cargando...' : 'Ingresar' }}
          </button>
        </div>
      </form>

      <div v-if="errorMessage" class="error-banner">
        {{ errorMessage }}
      </div>

    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';


const isLoading = ref(false);
const errorMessage = ref('');

const form = reactive({
  user_name: '',
  user_password: '',
  user_type: 'cliente' 
});

const router = useRouter()

const handleLogin = async () => {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    const response = await fetch('http://localhost:3000/api/users/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        p_search_name: form.user_name,
        p_search_pass: form.user_password,
        p_search_type: form.user_type
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || 'Error de conexión');
    }

    localStorage.setItem('user_session', JSON.stringify({
      user_id: data.o_user_id,
      user_name: data.o_user_name,
      user_type: data.o_user_type,
      created_at: data.o_created_at
    }));

    alert('Login exitoso. Bienvenido ' + data.o_user_name);
    
    router.push('/dashboard'); 

  } catch (error) {
    errorMessage.value = error.message;
    console.error('Login error:', error);
  } finally {
    isLoading.value = false;
  }
};
</script>

<style scoped>
/* Styles matching the aesthetic of Page 7 
   Colors: Pink (#e91e63) for primary actions, Cyan (#58bbc9) for links/secondary 
*/

* {
  box-sizing: border-box;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f8f9fa;
}

.login-card {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  width: 100%;
  max-width: 450px;
}

.title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #333;
  margin-bottom: 1.5rem;
}

/* Role Selection Styles */
.role-group {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #eee;
}

.role-label {
  display: block;
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 0.5rem;
}

.radio-options {
  display: flex;
  gap: 15px;
}

.radio-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  font-size: 0.9rem;
}

.radio-item input {
  margin-right: 5px;
  accent-color: #e91e63;
}

/* Form Inputs */
.form-group {
  margin-bottom: 1.2rem;
}

.form-group label {
  display: block;
  font-size: 0.9rem;
  font-weight: 600;
  color: #444;
  margin-bottom: 0.5rem;
}

.form-group input[type="text"],
.form-group input[type="password"] {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.form-group input:focus {
  border-color: #e91e63;
  outline: none;
}

/* Options */
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  font-size: 0.9rem;
}

.checkbox-container {
  display: flex;
  align-items: center;
  color: #666;
  cursor: pointer;
}

.checkbox-container input {
  margin-right: 8px;
  accent-color: #e91e63;
}

.forgot-password {
  color: #58bbc9;
  text-decoration: none;
}

.forgot-password:hover {
  text-decoration: underline;
}

/* Buttons */
.button-group {
  display: flex;
  gap: 1rem;
}

.btn {
  flex: 1;
  padding: 0.8rem;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.btn-primary {
  background-color: #e91e63;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #d81557;
}

.btn-primary:disabled {
  background-color: #fab1c7;
  cursor: not-allowed;
}

.btn-secondary {
  background-color: white;
  color: #58bbc9;
  border: 1px solid #58bbc9;
}

.btn-secondary:hover {
  background-color: #f0fbff;
}

.error-banner {
  margin-top: 1rem;
  padding: 0.75rem;
  background-color: #fee2e2;
  color: #b91c1c;
  border-radius: 6px;
  font-size: 0.9rem;
  text-align: center;
}
</style>