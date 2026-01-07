<template>
    <div class="wishlist-page">
        <header class="wishlist-header">
            <h2>Mi Lista de Deseos</h2>

            <div class="filter-bar">
                <button v-for="f in ['TODO', 'SERVICIO', 'TRASLADO', 'PAQUETE']" :key="f"
                    :class="['filter-btn', { active: filtroActual === f }]" @click="cambiarFiltro(f)">
                    {{ f === 'TODO' ? 'TODOS' : f + 'S' }}
                </button>
            </div>
        </header>

        <div v-if="loading" class="loader-container">
            <div class="spinner"></div>
            <p>Cargando {{ filtroActual.toLowerCase() }}s...</p>
        </div>

        <div v-else-if="items.length > 0" class="items-grid">
            <div v-for="item in items" :key="item.tipo_producto + item.codigo_producto" class="card">
                <div class="card-tag" :class="item.tipo_producto.toLowerCase()">
                    {{ item.tipo_producto }}
                </div>

                <div class="card-content">
                    <h3>{{ item.nombre_producto }}</h3>
                    <p>{{ item.descripcion_producto }}</p>
                    <div class="price-container">
                        <span class="price-label">Precio:</span>
                        <span class="price-value">${{ item.precio || '0.00' }}</span>
                    </div>
                </div>

                <div class="card-actions">
                    <button class="btn-view" @click="abrirDetalle(item)">Ver Detalles</button>
                    <button class="btn-delete" @click="removeItem(item.codigo_producto, item.tipo_producto)">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </div>
            </div>
        </div>

        <div v-else class="empty-state">
            <div class="icon-circle">🔎</div>
            <h2>No hay {{ filtroActual.toLowerCase() }}s</h2>
            <p>Intenta con otra categoría o explora nuestras ofertas.</p>
        </div>
    </div>

    <div v-if="showModal" class="modal-overlay" @click.self="cerrarDetalle">
        <div class="modal-content">
            <div class="modal-header" :class="selectedItem.tipo_producto.toLowerCase()">
                <h2>{{ selectedItem.nombre_producto }}</h2>
                <button class="close-btn" @click="cerrarDetalle">&times;</button>
            </div>
            <div class="modal-body">
                <p><strong>Categoría:</strong> {{ selectedItem.tipo_producto }}</p>
                <p><strong>Precio:</strong> ${{ selectedItem.precio || '0.00' }}</p>
                <p><strong>Descripción:</strong> {{ selectedItem.descripcion_producto }}</p>
            </div>
            <div class="modal-footer">
                <button @click="cerrarDetalle" class="btn-secondary">Cerrar</button>
            </div>
        </div>
    </div>

</template>

<script setup>
import { ref, onMounted } from 'vue';

// Variables reactivas
const items = ref([]);
const loading = ref(true);
const userId = ref(null);
const filtroActual = ref('TODO');
const showModal = ref(false);
const selectedItem = ref(null);

const abrirDetalle = (item) => {
    selectedItem.value = item;
    showModal.value = true;
};

const cerrarDetalle = () => {
    showModal.value = false;
    selectedItem.value = null;
};

// Carga inicial al montar el componente
onMounted(async () => {
    const session = JSON.parse(localStorage.getItem('user_session'));
    if (session && session.user_id) {
        userId.value = session.user_id;
        await fetchWishlist();
    } else {
        loading.value = false;
        console.error("No se encontró sesión de usuario");
    }
});

// Función principal para obtener datos del Backend
const fetchWishlist = async () => {
    if (!userId.value) return;

    loading.value = true;
    try {
        const categoriaParaBD = filtroActual.value.toUpperCase();

        const response = await fetch(
            `http://localhost:3000/api/wishlist/${userId.value}?categoria=${categoriaParaBD}`
        );

        if (!response.ok) throw new Error("Error en la respuesta del servidor");

        const data = await response.json();
        console.log("Datos que vienen del servidor:", data);

        // CORRECCIÓN AQUÍ: Debes entrar a data.items porque el servidor
        // envía { success: true, items: [...] }
        if (data.success && Array.isArray(data.items)) {
            items.value = data.items; 
        } else {
            // Si el backend envía el arreglo directo por algún cambio:
            items.value = Array.isArray(data) ? data : [];
        }
        
    } catch (error) {
        console.error("Error al conectar con la API:", error);
        items.value = []; // Limpiar para evitar estados inconsistentes
    } finally {
        loading.value = false;
    }
};
// Manejador de clics en filtros
const cambiarFiltro = (nuevoFiltro) => {
    filtroActual.value = nuevoFiltro;
    fetchWishlist();
};

// Eliminar un ítem de la wishlist
const removeItem = async (id, tipo) => {
    if (confirm(`¿Deseas eliminar este ${tipo.toLowerCase()}?`)) {
        try {
            const response = await fetch(`http://localhost:3000/api/wishlist/remove`, {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    user_id: userId.value, // Usamos la variable reactiva del componente
                    producto_id: id,
                    tipo_producto: tipo.toUpperCase() // Forzamos mayúsculas
                })
            });

            const data = await response.json();
            
            if (data.success) {
                // Refrescamos la lista inmediatamente para ver el cambio
                await fetchWishlist();
            }
        } catch (error) {
            console.error("Error al eliminar:", error);
        }
    }
};
</script>

<style scoped>
.wishlist-page {
    padding: 40px 5%;
    background: #f8fafc;
    min-height: 100vh;
}

.wishlist-header {
    text-align: center;
    margin-bottom: 40px;
}

.wishlist-header h2 {
    font-size: 2rem;
    color: #1e293b;
    margin-bottom: 20px;
}

/* Barra de Filtros */
.filter-bar {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
}

.filter-btn {
    padding: 10px 24px;
    border-radius: 30px;
    border: 1px solid #e2e8f0;
    background: white;
    color: #64748b;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.2s ease;
}

.filter-btn:hover {
    background: #f1f5f9;
    border-color: #cbd5e1;
}

.filter-btn.active {
    background: #3b82f6;
    color: white;
    border-color: #3b82f6;
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

/* Rejilla y Tarjetas */
.items-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 25px;
}

.card {
    background: white;
    border-radius: 16px;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    transition: transform 0.2s;
}

.card:hover {
    transform: translateY(-5px);
}

/* Colores de Tags según el tipo de la BD */
.card-tag {
    padding: 6px 16px;
    font-size: 0.75rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

.paquete {
    background: #e0f2fe;
    color: #0369a1;
}

.servicio {
    background: #fef3c7;
    color: #92400e;
}

.traslado {
    background: #dcfce7;
    color: #166534;
}

.card-content {
    padding: 24px;
    flex-grow: 1;
}

.card-content h3 {
    color: #1e293b;
    margin-bottom: 8px;
}

.card-content p {
    color: #64748b;
    font-size: 0.95rem;
    line-height: 1.5;
}

.card-actions {
    padding: 16px 24px;
    background: #f8fafc;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.btn-view {
    background: #3b82f6;
    color: white;
    border: none;
    padding: 8px 20px;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
}

.btn-delete {
    background: #fee2e2;
    color: #ef4444;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 10px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* Estados */
.loader-container {
    text-align: center;
    padding: 100px;
    color: #64748b;
}

.empty-state {
    text-align: center;
    padding: 80px;
}

.icon-circle {
    font-size: 3rem;
    margin-bottom: 20px;
}

/* Estilos para el Modal */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
    backdrop-filter: blur(4px);
    /* Efecto de desenfoque al fondo */
}

.modal-content {
    background: white;
    width: 90%;
    max-width: 500px;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
    from {
        transform: translateY(20px);
        opacity: 0;
    }

    to {
        transform: translateY(0);
        opacity: 1;
    }
}

.modal-header {
    padding: 24px;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

/* Reutilizamos tus colores para el header del modal */
.modal-header.paquete {
    background: #0ea5e9;
}

.modal-header.servicio {
    background: #f59e0b;
}

.modal-header.traslado {
    background: #10b981;
}

.modal-header h2 {
    margin: 0;
    font-size: 1.5rem;
}

.close-btn {
    background: none;
    border: none;
    color: white;
    font-size: 2rem;
    cursor: pointer;
    line-height: 1;
}

.modal-body {
    padding: 24px;
    color: #475569;
}

.modal-body p {
    margin-bottom: 15px;
    line-height: 1.6;
}

.modal-footer {
    padding: 16px 24px;
    background: #f8fafc;
    border-top: 1px solid #e2e8f0;
    text-align: right;
}

.btn-secondary {
    background: #94a3b8;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
}

/* Estilos para el precio en la tarjeta */
.price-container {
    margin-top: 15px;
    padding-top: 10px;
    border-top: 1px dashed #e2e8f0;
    display: flex;
    align-items: center;
    gap: 8px;
}

.price-label {
    font-size: 0.85rem;
    color: #64748b;
    font-weight: 600;
}

.price-value {
    font-size: 1.1rem;
    color: #1e293b;
    font-weight: 800;
}
</style>