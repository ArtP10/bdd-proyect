<template>
  <div class="login-container">
    <div class="login-card">
      <h2 class="title">Registro de Cliente</h2>
      <p class="subtitle">Únete a Viajes Ucab y comienza a volar.</p>

      <form @submit.prevent="handleRegister">
        
        <div class="form-group">
          <label for="reg-username">Nombre de Usuario</label>
          <input 
            id="reg-username" 
            type="text" 
            v-model="form.user_name" 
            placeholder="Ej. juanperez" 
            required
          />
        </div>

        <div class="form-group">
          <label for="reg-email">Correo Electrónico</label>
          <input 
            id="reg-email" 
            type="email" 
            v-model="form.user_email" 
            placeholder="juan@ejemplo.com" 
            required
          />
        </div>

        <div class="form-group">
          <label for="reg-password">Contraseña</label>
          <input 
            id="reg-password" 
            type="password" 
            v-model="form.user_password" 
            placeholder="••••••••" 
            required
          />
        </div>

        <div class="form-group">
            <label for="reg-location">Lugar de Residencia (Estado)</label>
            <select id="reg-location" v-model="form.fk_lugar" required>
                <option value="" disabled>Seleccione su estado</option>
                <option v-for="loc in locations" :key="loc.lug_codigo" :value="loc.lug_codigo">
                    {{ loc.lug_nombre }}
                </option>
            </select>
        </div>

        <div class="button-group">
          <button type="submit" class="btn btn-primary" :disabled="isLoading">
            {{ isLoading ? 'Registrando...' : 'Crear Cuenta' }}
          </button>
        </div>

        <div class="register-link">
            <button type="button" @click="router.push('/login')" class="btn-link">
                ← Volver al Login
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
import { reactive, ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const isLoading = ref(false);
const errorMessage = ref('');
const locations = ref([]); // Lista de estados

const form = reactive({
  user_name: '',
  user_email: '',
  user_password: '',
  fk_lugar: '' // Nuevo campo en el formulario
});

// 1. Función para cargar los lugares (Estados)
const fetchLocations = async () => {
    try {
        // Usamos el mismo endpoint que creamos para el admin, ya que filtra por Estado/Pais
        const response = await fetch('http://localhost:3000/api/users/locations/list');
        const data = await response.json();
        if (data.success) {
            locations.value = data.data;
        }
    } catch (error) {
        console.error("Error cargando lugares:", error);
    }
};

const handleRegister = async () => {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    const response = await fetch('http://localhost:3000/api/users/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: form.user_name,
        password: form.user_password,
        email: form.user_email,
        fk_lugar: form.fk_lugar // 2. Enviamos el lugar al backend
      }),
    });

    const data = await response.json();

    if (!response.ok || !data.success) {
      throw new Error(data.message || 'Error al registrar usuario');
    }

    // Auto-login: Guardar sesión
    localStorage.setItem('user_session', JSON.stringify({
      user_id: data.data.usu_codigo,
      user_name: form.user_name,
      user_role: 'Cliente',
      user_email: form.user_email
    }));

    alert('Registro exitoso. Bienvenido a Viajes Ucab.');
    router.push('/client/dashboard');

  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    isLoading.value = false;
  }
};

// 3. Cargar lugares al montar el componente
onMounted(() => {
    fetchLocations();
});
</script>

<style scoped>
/* Reutilizamos estilos existentes */
* { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
.login-container { min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: #f8f9fa; }
.login-card { background: white; padding: 2.5rem; border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08); width: 100%; max-width: 450px; }
.title { font-size: 1.5rem; font-weight: 700; color: #333; margin-bottom: 0.5rem; text-align: center;}
.subtitle { color: #666; font-size: 0.95rem; margin-bottom: 1.5rem; text-align: center; }
.form-group { margin-bottom: 1.2rem; }
.form-group label { display: block; font-size: 0.9rem; font-weight: 600; color: #444; margin-bottom: 0.5rem; }
/* Estilo para inputs y selects */
.form-group input, .form-group select { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 6px; font-size: 1rem; transition: border-color 0.2s; background-color: white; }
.form-group input:focus, .form-group select:focus { border-color: #e91e63; outline: none; }
.button-group { display: flex; gap: 1rem; margin-top: 1.5rem; }
.btn { flex: 1; padding: 0.8rem; border-radius: 6px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: all 0.2s; border: none; }
.btn-primary { background-color: #e91e63; color: white; }
.btn-primary:hover:not(:disabled) { background-color: #d81557; }
.btn-primary:disabled { background-color: #fab1c7; cursor: not-allowed; }
.error-banner { margin-top: 1rem; padding: 0.75rem; background-color: #fee2e2; color: #b91c1c; border-radius: 6px; font-size: 0.9rem; text-align: center; }
.register-link { margin-top: 1rem; text-align: center; }
.btn-link { background: none; border: none; color: #666; cursor: pointer; text-decoration: none; font-size: 0.9rem; }
.btn-link:hover { text-decoration: underline; color: #333; }
</style>