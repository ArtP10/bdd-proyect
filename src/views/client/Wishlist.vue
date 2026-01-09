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
                
                <div class="card-header-tags">
                    <div class="card-tag" :class="item.tipo_producto.toLowerCase()">
                        {{ item.tipo_producto }}
                    </div>
                    
                    <div v-if="esVencido(item.fecha_inicio)" class="tag-vencido">
                        <i class="fa-solid fa-calendar-xmark"></i> Vencido
                    </div>

                    <div v-else-if="item.porcentaje_descuento > 0" class="tag-oferta">
                        -{{ item.porcentaje_descuento }}%
                    </div>
                </div>

                <div class="card-content">
                    <h3>{{ item.nombre_producto }}</h3>
                    <p class="desc-text">{{ item.descripcion_producto }}</p>
                    
                    <div class="date-info" v-if="item.fecha_inicio">
                        <small><i class="fa-regular fa-calendar"></i> {{ formatDate(item.fecha_inicio) }}</small>
                    </div>

                    <div class="price-container">
                        <span class="price-label">Precio:</span>
                        
                        <div v-if="item.porcentaje_descuento > 0 && !esVencido(item.fecha_inicio)" class="price-wrapper">
                            <span class="price-old">${{ item.precio_original }}</span>
                            <span class="price-value text-offer">${{ item.precio_final }}</span>
                        </div>
                        
                        <div v-else>
                            <span class="price-value">${{ item.precio_original || '0.00' }}</span>
                        </div>
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
                <p><strong>Fecha:</strong> {{ formatDate(selectedItem.fecha_inicio) }}</p>
                
                <div v-if="selectedItem.porcentaje_descuento > 0 && !esVencido(selectedItem.fecha_inicio)">
                    <p><strong>Precio Original:</strong> <span style="text-decoration: line-through;">${{ selectedItem.precio_original }}</span></p>
                    <p class="text-offer"><strong>Precio Oferta:</strong> ${{ selectedItem.precio_final }}</p>
                </div>
                <div v-else>
                    <p><strong>Precio:</strong> ${{ selectedItem.precio_original || '0.00' }}</p>
                </div>

                <hr>
                <p><strong>Descripción:</strong></p>
                <p>{{ selectedItem.descripcion_producto }}</p>
            </div>
            <div class="modal-footer">
                <button @click="cerrarDetalle" class="btn-secondary">Cerrar</button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// 1. CORRECCIÓN DEL WARNING: Recibir la prop 'userId' aunque sea opcional
const props = defineProps(['userId']);

// Variables reactivas
const items = ref([]);
const loading = ref(true);
const currentUserId = ref(null);
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

// 2. HELPER: Verificar si venció
const esVencido = (fecha) => {
    if (!fecha) return false;
    return new Date(fecha) < new Date();
};

// 3. HELPER: Formato de fecha amigable
const formatDate = (dateString) => {
    if (!dateString) return 'Sin fecha';
    const d = new Date(dateString);
    return d.toLocaleDateString('es-VE', { 
        day: '2-digit', 
        month: 'short', 
        year: 'numeric', 
        hour: '2-digit', 
        minute:'2-digit' 
    });
};

// Carga inicial
onMounted(async () => {
    // Prioridad: 1. Prop del padre, 2. LocalStorage
    if (props.userId) {
        currentUserId.value = props.userId;
    } else {
        const session = JSON.parse(localStorage.getItem('user_session'));
        if (session && session.user_id) {
            currentUserId.value = session.user_id;
        }
    }

    if (currentUserId.value) {
        await fetchWishlist();
    } else {
        loading.value = false;
        console.error("No se encontró sesión de usuario");
    }
});

// Función principal para obtener datos
const fetchWishlist = async () => {
    if (!currentUserId.value) return;

    loading.value = true;
    try {
        const categoriaParaBD = filtroActual.value.toUpperCase();

        const response = await fetch(
            `http://localhost:3000/api/wishlist/${currentUserId.value}?categoria=${categoriaParaBD}`
        );

        if (!response.ok) throw new Error("Error en la respuesta del servidor");

        const data = await response.json();
        console.log("Datos Wishlist:", data);

        if (data.success && Array.isArray(data.items)) {
            items.value = data.items; 
        } else {
            items.value = [];
        }
        
    } catch (error) {
        console.error("Error API:", error);
        items.value = []; 
    } finally {
        loading.value = false;
    }
};

const cambiarFiltro = (nuevoFiltro) => {
    filtroActual.value = nuevoFiltro;
    fetchWishlist();
};

const removeItem = async (id, tipo) => {
    if (confirm(`¿Deseas eliminar este ${tipo.toLowerCase()}?`)) {
        try {
            const response = await fetch(`http://localhost:3000/api/wishlist/remove`, {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    user_id: currentUserId.value,
                    producto_id: id,
                    tipo_producto: tipo.toUpperCase()
                })
            });

            const data = await response.json();
            
            if (data.success) {
                // Refrescamos para que desaparezca solo el eliminado
                await fetchWishlist();
            } else {
                alert("Error al eliminar: " + (data.message || 'Desconocido'));
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
    font-family: 'Segoe UI', sans-serif;
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
    border: 1px solid #f1f5f9;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

/* Header de la tarjeta con Tags */
.card-header-tags {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 15px 0 15px;
}

.card-tag {
    padding: 4px 10px;
    font-size: 0.7rem;
    font-weight: 800;
    text-transform: uppercase;
    border-radius: 4px;
    letter-spacing: 0.05em;
}

.paquete { background: #e0f2fe; color: #0369a1; }
.servicio { background: #fef3c7; color: #92400e; }
.traslado { background: #dcfce7; color: #166534; }

/* Tags de Estado */
.tag-vencido {
    background: #fee2e2;
    color: #ef4444;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.7rem;
    font-weight: bold;
    text-transform: uppercase;
    display: flex;
    align-items: center;
    gap: 5px;
}

.tag-oferta {
    background: #E91E63;
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: bold;
    animation: pulse 2s infinite;
}

/* Contenido */
.card-content {
    padding: 15px 24px 24px 24px;
    flex-grow: 1;
}

.card-content h3 {
    color: #1e293b;
    margin: 0 0 8px 0;
    font-size: 1.1rem;
}

.desc-text {
    color: #64748b;
    font-size: 0.9rem;
    line-height: 1.5;
    margin-bottom: 10px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.date-info {
    margin-bottom: 15px;
    color: #94a3b8;
    font-size: 0.85rem;
}

/* Precio */
.price-container {
    padding-top: 15px;
    border-top: 1px dashed #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
}

.price-label {
    font-size: 0.8rem;
    color: #64748b;
    font-weight: 600;
}

.price-wrapper {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
}

.price-old {
    text-decoration: line-through;
    color: #94a3b8;
    font-size: 0.85rem;
}

.price-value {
    font-size: 1.2rem;
    color: #1e293b;
    font-weight: 800;
}

.text-offer {
    color: #E91E63;
}

/* Acciones */
.card-actions {
    padding: 16px 24px;
    background: #f8fafc;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #f1f5f9;
}

.btn-view {
    background: #3b82f6;
    color: white;
    border: none;
    padding: 8px 20px;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
}
.btn-view:hover { background: #2563eb; }

.btn-delete {
    background: white;
    border: 1px solid #fee2e2;
    color: #ef4444;
    width: 36px;
    height: 36px;
    border-radius: 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
}
.btn-delete:hover { background: #fee2e2; }

/* Modal */
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
}

.modal-content {
    background: white;
    width: 90%;
    max-width: 500px;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    animation: fadeIn 0.3s ease-out;
}

.modal-header {
    padding: 20px 24px;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.modal-header.paquete { background: #0ea5e9; }
.modal-header.servicio { background: #f59e0b; }
.modal-header.traslado { background: #10b981; }

.modal-header h2 { margin: 0; font-size: 1.3rem; }
.close-btn { background: none; border: none; color: white; font-size: 1.5rem; cursor: pointer; }

.modal-body { padding: 24px; color: #334155; }
.modal-footer { padding: 15px 24px; background: #f8fafc; text-align: right; border-top: 1px solid #e2e8f0; }
.btn-secondary { background: #94a3b8; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; }

/* Animaciones y Estados */
.loader-container, .empty-state { text-align: center; padding: 80px; color: #64748b; }
.spinner { border: 4px solid #f3f3f3; border-top: 4px solid #3b82f6; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto 15px; }
.icon-circle { font-size: 3rem; margin-bottom: 15px; }

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
@keyframes fadeIn { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
@keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.05); } 100% { transform: scale(1); } }
</style>