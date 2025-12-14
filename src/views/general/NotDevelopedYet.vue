<template>
  <div class="not-developed-container">
    <div class="card">
      <div class="icon">🚧</div>
      <h1>Módulo en Construcción</h1>
      <p>
        Hola, <strong>{{ providerName }}</strong>.
      </p>
      <p>
        Actualmente, la plataforma solo tiene habilitado el módulo de gestión para 
        <strong>Aerolíneas</strong>.
      </p>
      <p class="subtext">
        El soporte para proveedores de tipo <strong>{{ providerType }}</strong> 
        está en desarrollo y estará disponible en futuras actualizaciones.
      </p>
      
      <button @click="logout" class="btn-primary">Cerrar Sesión</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const providerName = ref('');
const providerType = ref('');

onMounted(() => {
    const session = JSON.parse(localStorage.getItem('user_session') || '{}');
    if (session) {
        providerName.value = session.user_name || 'Proveedor';
        providerType.value = session.provider_type || 'Desconocido';
    }
});

const logout = () => {
    localStorage.removeItem('user_session');
    router.push('/');
};
</script>

<style scoped>
.not-developed-container {
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #f1f5f9;
}

.card {
    background: white;
    padding: 40px;
    border-radius: 12px;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    text-align: center;
    max-width: 500px;
}

.icon { font-size: 4rem; margin-bottom: 20px; }
h1 { color: #1e293b; margin-bottom: 15px; }
p { color: #475569; font-size: 1.1rem; line-height: 1.5; margin-bottom: 10px; }
.subtext { font-size: 0.95rem; color: #64748b; margin-top: 20px; margin-bottom: 30px; }

.btn-primary {
    background: #3b82f6; color: white; border: none;
    padding: 12px 25px; border-radius: 6px;
    font-size: 1rem; font-weight: 600; cursor: pointer;
    transition: 0.2s;
}
.btn-primary:hover { background: #2563eb; }
</style>