<template>
  <div class="login-container">
    <div class="login-card">
      <h2 class="title">Iniciar sesión en Viajes Ucab</h2>
      <form @submit.prevent="handleLogin">
        
        <div class="role-group">
          <label class="role-label">Ingresar como:</label>
          <div class="radio-options">
            <label class="radio-item">
              <input type="radio" name="role" value="Cliente" v-model="form.user_type">
              <span>Cliente</span>
            </label>
            <label class="radio-item">
              <input type="radio" name="role" value="Proveedor" v-model="form.user_type">
              <span>Proveedor</span>
            </label>
            <label class="radio-item">
              <input type="radio" name="role" value="Administrador" v-model="form.user_type">
              <span>Administrador</span>
            </label>
          </div>
        </div>

        <div class="form-group">
          <label for="username">Usuario</label>
          <input id="username" type="text" v-model="form.user_name" placeholder="tuNombre" required />
        </div>

        <div class="form-group">
          <label for="password">Contraseña</label>
          <input id="password" type="password" v-model="form.user_password" placeholder="••••••••" required />
        </div>

        <div class="button-group">
          <button type="submit" class="btn btn-primary" :disabled="isLoading">
            {{ isLoading ? 'Cargando...' : 'Ingresar' }}
          </button>
        </div>
      </form>

      <div class="register-link" v-if="form.user_type === 'Cliente'">
        <p>¿No tienes cuenta?</p>
        <button @click="goToRegister" class="btn-link">Registrarse como Cliente</button>
      </div>

      <div v-if="errorMessage" class="error-banner">{{ errorMessage }}</div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';

const isLoading = ref(false);
const errorMessage = ref('');
const router = useRouter();

const form = reactive({
  user_name: '',
  user_password: '',
  user_type: 'Cliente'
});

const goToRegister = () => {
  router.push('/client/register');
};

const handleLogin = async () => {
    isLoading.value = true; // Feedback visual
    try {
        const response = await fetch('http://localhost:3000/api/users/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                username: form.user_name,     
                password: form.user_password
            })
        });
        const data = await response.json();

        if (data.success) {
            localStorage.setItem('user_session', JSON.stringify(data.user));
            // Guardamos el rol para validaciones rápidas en el front
            localStorage.setItem('userRole', data.user.role); 

            if (data.user.role === 'Administrador') {
                router.push('/admin/dashboard');
            } 
            else if (data.user.role === 'Proveedor') {
                if (data.user.provider_type === 'Aerolinea') {
                    // Nota: Asegúrate que la ruta '/provider/dashboard' exista en tu router o ajústala
                    router.push('/providers/airlines/dashboard'); 
                } else {
                    router.push('/not-developed');
                }
            } 
            else if (data.user.role === 'Cliente') {
                // CAMBIO PRINCIPAL: Redirigir al Home en lugar del dashboard
                router.push('/');
            }
        } else {
            errorMessage.value = data.message; // Mostrar error en el banner
        }
    } catch (error) {
        console.error(error);
        errorMessage.value = 'Error de conexión con el servidor';
    } finally {
        isLoading.value = false;
    }
};
</script>

<style scoped>
/* Estilos se mantienen igual */
* { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
.login-container { min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: #f8f9fa; }
.login-card { background: white; padding: 2.5rem; border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08); width: 100%; max-width: 450px; }
.title { font-size: 1.5rem; font-weight: 700; color: #333; margin-bottom: 1.5rem; text-align: center; }
.role-group { margin-bottom: 1.5rem; padding-bottom: 1rem; border-bottom: 1px solid #eee; }
.role-label { display: block; font-size: 0.9rem; color: #666; margin-bottom: 0.5rem; }
.radio-options { display: flex; gap: 15px; justify-content: center; }
.radio-item { display: flex; align-items: center; cursor: pointer; font-size: 0.9rem; user-select: none; }
.radio-item input { margin-right: 6px; accent-color: #e91e63; transform: scale(1.1); }
.form-group { margin-bottom: 1.2rem; }
.form-group label { display: block; font-size: 0.9rem; font-weight: 600; color: #444; margin-bottom: 0.5rem; }
.form-group input[type="text"], .form-group input[type="password"] { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 6px; font-size: 1rem; transition: border-color 0.2s; }
.form-group input:focus { border-color: #e91e63; outline: none; box-shadow: 0 0 0 3px rgba(233, 30, 99, 0.1); }
.button-group { display: flex; gap: 1rem; margin-top: 1rem; }
.btn { flex: 1; padding: 0.8rem; border-radius: 6px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: all 0.2s; border: none; }
.btn-primary { background-color: #e91e63; color: white; }
.btn-primary:hover:not(:disabled) { background-color: #d81557; transform: translateY(-1px); }
.btn-primary:disabled { background-color: #fab1c7; cursor: not-allowed; }
.register-link { margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid #eee; text-align: center; font-size: 0.9rem; }
.btn-link { background: none; border: none; color: #e91e63; font-weight: 700; cursor: pointer; text-decoration: underline; padding: 0; margin-top: 0.25rem; }
.error-banner { margin-top: 1rem; padding: 0.75rem; background-color: #fee2e2; color: #b91c1c; border-radius: 6px; font-size: 0.9rem; text-align: center; border: 1px solid #fecaca; }
</style>