<template>
  <div class="container-fluid">
    <div class="header-actions">
      <div>
        <h2>📦 Gestión de Paquetes</h2>
        <p class="subtitle">Administra paquetes y reglas de negocio</p>
      </div>
      
      <div class="btn-group-header">
        <button @click="openRuleManager" class="btn-secondary">
            <i class="fa-solid fa-scale-balanced"></i> Gestionar Reglas
        </button>
        <button @click="openCreateModal" class="btn-main">
            <i class="fa-solid fa-plus"></i> Crear Paquete Base
        </button>
      </div>
    </div>

    <div class="table-card">
      <table class="styled-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nombre del Paquete</th>
            <th>Costo Total ($)</th>
            <th>Costo (Millas)</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in packages" :key="p.paq_tur_codigo">
            <td><span class="id-tag">#{{ p.paq_tur_codigo }}</span></td>
            <td class="font-bold">{{ p.paq_tur_nombre }}</td>
            <td class="amount-text">${{ formatCurrency(p.paq_tur_monto_total) }}</td>
            <td><span class="miles-tag">🌟 {{ p.paq_tur_costo_en_millas }}</span></td>
            <td class="text-center">
              <div class="action-group">
                <button class="action-btn btn-view" @click="openDetailsModal(p.paq_tur_codigo)" title="Ver Detalle">
                  <i class="fa-solid fa-eye"></i>
                </button>
                <button class="action-btn btn-config" @click="openConfigModal(p)" title="Configurar Contenido">
                  <i class="fa-solid fa-gear"></i>
                </button>
                <button class="action-btn btn-edit" @click="openEditModal(p)" title="Editar">
                  <i class="fa-solid fa-pen"></i>
                </button>
                <button class="action-btn btn-delete" @click="deletePackage(p.paq_tur_codigo)" title="Eliminar">
                  <i class="fa-solid fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="packages.length === 0">
              <td colspan="5" class="empty-text">
                <div class="empty-state">
                    <i class="fa-solid fa-box-open"></i>
                    <p>No hay paquetes registrados aún.</p>
                </div>
              </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showModal" class="modal-backdrop" @click.self="showModal=false">
      <div class="modal-window slide-in">
        <div class="modal-header">
            <h3>{{ isEditing ? '✏️ Editar Paquete' : '✨ Nuevo Paquete' }}</h3>
            <button class="close-icon" @click="showModal=false">✕</button>
        </div>
        <form @submit.prevent="savePackage">
            <div class="modal-body">
                <div class="form-group">
                    <label>Nombre del Paquete</label>
                    <input v-model="form.nombre" required placeholder="Ej: Viaje Mágico a Canaima" class="input-field">
                </div>
                <div class="form-group">
                    <label>Descripción Corta</label>
                    <input v-model="form.descripcion" required placeholder="Ej: 3 Días / 2 Noches todo incluido" class="input-field">
                </div>
                <div class="row-inputs">
                    <div class="form-group">
                        <label>Costo Total ($)</label>
                        <input type="number" step="0.01" v-model="form.monto_total" required class="input-field">
                    </div>
                    <div class="form-group">
                        <label>Subtotal ($)</label>
                        <input type="number" step="0.01" v-model="form.monto_subtotal" required class="input-field">
                    </div>
                </div>
                <div class="form-group">
                    <label>Costo en Millas</label>
                    <input type="number" v-model="form.costo_millas" required class="input-field">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" @click="showModal=false" class="btn-secondary">Cancelar</button>
                <button type="submit" class="btn-main">{{ isEditing ? 'Actualizar' : 'Guardar' }}</button>
            </div>
        </form>
      </div>
    </div>

    <div v-if="showRuleManager" class="modal-backdrop" @click.self="showRuleManager=false">
        <div class="modal-window large slide-in">
            <div class="modal-header">
                <h3>⚖️ Gestión de Reglas de Negocio</h3>
                <button class="close-icon" @click="showRuleManager=false">✕</button>
            </div>
            <div class="modal-body">
                
                <div class="assign-form">
                    <label>{{ isEditingRule ? '✏️ Editar Regla' : '✨ Nueva Regla' }}</label>
                    <div class="input-group-row">
                        
                        <div class="form-group flex-grow">
                            <select v-model="ruleForm.atributo" class="input-field">
                                <option value="" disabled>Seleccione Atributo...</option>
                                <option v-for="opt in attributeOptions" :key="opt.value" :value="opt.value">
                                    {{ opt.label }}
                                </option>
                            </select>
                        </div>

                        <div class="form-group" style="width: 120px;">
                            <select v-model="ruleForm.operador" class="input-field">
                                <option value="=">Igual (=)</option>
                                <option value=">">Mayor (>)</option>
                                <option value="<">Menor (<)</option>
                                <option value=">=">Mayor o Igual (>=)</option>
                                <option value="<=">Menor o Igual (<=)</option>
                                <option value="<>">Diferente (<>)</option>
                            </select>
                        </div>

                        <div class="form-group flex-grow">
                            <input v-model="ruleForm.valor" placeholder="Valor (Ej: 18, Soltero, Caracas)" class="input-field">
                        </div>

                        <div class="form-group btn-container">
                            <button class="btn-add" @click="saveRule">{{ isEditingRule ? 'Actualizar' : 'Crear' }}</button>
                            <button v-if="isEditingRule" class="btn-secondary small" @click="cancelEditRule">Cancelar</button>
                        </div>
                    </div>

                    <div v-if="ruleForm.atributo" class="hint-text">
                        <i class="fa-solid fa-circle-info"></i>
                        <span v-if="ruleForm.atributo === 'viajero_edad'"> Validará la edad numérica del viajero principal.</span>
                        <span v-else-if="ruleForm.atributo === 'usuario_millas'"> Validará el saldo de millas del usuario comprador.</span>
                        <span v-else-if="ruleForm.atributo === 'viajero_estado_civil'"> Validará el estado civil actual (Ej: Soltero, Casado).</span>
                        <span v-else> Escriba el valor exacto con el que desea comparar.</span>
                    </div>
                </div>

                <div class="table-card mt-2">
                    <table class="styled-table">
                        <thead>
                            <tr>
                                <th>Atributo</th>
                                <th>Condición</th>
                                <th>Valor</th>
                                <th class="text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="r in listRules" :key="r.reg_paq_codigo">
                                <td>
                                    <span class="badge-attr">
                                        {{ attributeOptions.find(o => o.value === r.reg_paq_atributo)?.label || r.reg_paq_atributo }}
                                    </span>
                                </td>
                                <td class="text-center font-bold">{{ r.reg_paq_operador }}</td>
                                <td>{{ r.reg_paq_valor }}</td>
                                <td class="text-center">
                                    <div class="action-group">
                                        <button class="action-btn btn-edit" @click="editRule(r)" title="Modificar">
                                            <i class="fa-solid fa-pen"></i>
                                        </button>
                                        <button class="action-btn btn-delete" @click="deleteRuleDefinition(r.reg_paq_codigo)" title="Eliminar Definitivamente">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <tr v-if="listRules.length === 0">
                                <td colspan="4" class="empty-text">No hay reglas definidas en el sistema.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div v-if="showConfigModal" class="modal-backdrop" @click.self="showConfigModal=false">
      <div class="modal-window large slide-in">
        <div class="modal-header config-header">
            <div>
                <small>Configurando:</small>
                <h3>{{ selectedPackage?.paq_tur_nombre }}</h3>
            </div>
            <button class="close-icon" @click="showConfigModal=false">✕</button>
        </div>

        <div class="tabs-header">
            <button :class="{ active: activeTab === 'reglas' }" @click="activeTab = 'reglas'"><i class="fa-solid fa-scroll"></i> Reglas</button>
            <button :class="{ active: activeTab === 'servicios' }" @click="activeTab = 'servicios'"><i class="fa-solid fa-ticket"></i> Servicios</button>
            <button :class="{ active: activeTab === 'habitacion' }" @click="activeTab = 'habitacion'"><i class="fa-solid fa-bed"></i> Hoteles</button>
            <button :class="{ active: activeTab === 'restaurante' }" @click="activeTab = 'restaurante'"><i class="fa-solid fa-utensils"></i> Restaurante</button>
            <button :class="{ active: activeTab === 'traslados' }" @click="activeTab = 'traslados'"><i class="fa-solid fa-plane"></i> Traslados</button>
        </div>

        <div class="modal-body tab-body">
            
            <div v-if="activeTab === 'reglas'">
                <div class="assign-form">
                    <label>Asignar Regla al Paquete:</label>
                    <div class="input-group">
                        <select v-model="selectedRuleId" class="input-field">
                            <option value="" disabled>Seleccione Regla...</option>
                            <option v-for="r in listRules" :value="r.reg_paq_codigo">
                                {{ attributeOptions.find(o => o.value === r.reg_paq_atributo)?.label || r.reg_paq_atributo }} 
                                {{ r.reg_paq_operador }} {{ r.reg_paq_valor }}
                            </option>
                        </select>
                        <button class="btn-add" @click="assignItem('regla')">Asignar</button>
                    </div>
                </div>
                <div class="current-list">
                    <h6>Reglas Activas en este Paquete:</h6>
                    <ul>
                        <li v-for="(item, i) in currentConfig.reglas" :key="i">
                            <span>
                                <span class="badge-attr-small">{{ item.atributo }}</span> 
                                {{ item.operador }} {{ item.valor }}
                            </span>
                            <button class="btn-remove" @click="deleteElement('regla', item)" title="Quitar del Paquete">✕</button>
                        </li>
                    </ul>
                </div>
            </div>

            <div v-if="activeTab === 'servicios'">
                <div class="assign-form">
                    <label>Agregar Servicio:</label>
                    <div class="input-group-row">
                        <select v-model="selectedServiceId" class="input-field flex-grow">
                            <option value="" disabled>Seleccione servicio...</option>
                            <option v-for="s in listGenericServices" :value="s.id">{{ s.nombre }} (${{s.costo}})</option>
                        </select>
                        <input type="number" v-model="serviceQty" class="input-field qty-input" min="1" placeholder="Cant.">
                        <button class="btn-add" @click="assignItem('servicio')">Agregar</button>
                    </div>
                </div>
                <div class="current-list">
                    <h6>Servicios Incluidos:</h6>
                    <ul>
                        <li v-for="(item, i) in currentConfig.servicios_genericos" :key="i">
                            <span>🎫 <b>{{ item.cantidad }}x</b> {{ item.nombre }} <small>({{ item.tipo }})</small></span>
                            <button class="btn-remove" @click="deleteElement('servicio', item)" title="Quitar">✕</button>
                        </li>
                    </ul>
                </div>
            </div>

            <div v-if="activeTab === 'traslados'">
                <div class="assign-form">
                    <label>Buscar Traslado:</label>
                    <input type="text" v-model="searchTransfer" placeholder="Escribe origen, destino o aerolínea..." class="input-field search-box">
                    
                    <label class="mt-2">Seleccionar Vuelo/Viaje:</label>
                    <div class="input-group">
                        <select v-model="selectedTransferId" class="input-field">
    <option value="" disabled>-- Resultados de búsqueda --</option>
    <option v-for="t in filteredTransfers" :value="t.id">
        {{ t.nombre }} | {{ t.descripcion }} | 💲{{ t.precio }}
    </option>
</select>
                        <button class="btn-add" @click="assignItem('traslado')">Agregar</button>
                    </div>
                </div>
                <div class="current-list">
                    <h6>Traslados Asignados:</h6>
                    <ul>
                        <li v-for="(item, i) in currentConfig.traslados" :key="i">
                            <div class="list-content">
                                <span class="badge-type">{{ item.tipo }}</span>
                                <span>{{ item.origen }} ➝ {{ item.destino }}</span>
                            </div>
                            <button class="btn-remove" @click="deleteElement('traslado', item)" title="Quitar">✕</button>
                        </li>
                    </ul>
                </div>
            </div>

            <div v-if="activeTab === 'habitacion'">
                <div class="assign-form">
                    <label>Reservar Habitación:</label>
                    <select v-model="roomForm.id_habitacion" class="input-field mb-2">
                        <option value="" disabled>Seleccione hotel y habitación...</option>
                        <option v-for="h in listRooms" :value="h.id">{{ h.info_hotel }} - {{ h.info_habitacion }} (${{ h.costo }})</option>
                    </select>
                    <div class="row-inputs">
                        <div class="form-group"><label>Entrada</label><input type="datetime-local" v-model="roomForm.fecha_inicio" class="input-field"></div>
                        <div class="form-group"><label>Salida</label><input type="datetime-local" v-model="roomForm.fecha_fin" class="input-field"></div>
                    </div>
                    <button class="btn-add full-width mt-2" @click="saveRoomReservation">Reservar Alojamiento</button>
                </div>
                <div class="current-list">
                    <h6>Alojamientos Reservados:</h6>
                    <ul>
                        <li v-for="(item, i) in currentConfig.alojamientos" :key="i">
                            <div>
                                <strong>🏨 {{ item.nombre_hotel }}</strong> ({{ item.habitacion }})
                                <br><small>📅 {{ item.entrada }} ➝ {{ item.salida }}</small>
                            </div>
                            <button class="btn-remove" @click="deleteElement('habitacion', item)" title="Quitar">✕</button>
                        </li>
                    </ul>
                </div>
            </div>

            <div v-if="activeTab === 'restaurante'">
                <div class="assign-form">
                    <label>Reservar Mesa:</label>
                    <select v-model="restForm.id_restaurante" class="input-field mb-2">
                        <option value="" disabled>Seleccione restaurante...</option>
                        <option v-for="r in listRestaurants" :value="r.id">{{ r.nombre }}</option>
                    </select>
                    <div class="row-inputs">
                        <div class="form-group"><label>Fecha/Hora</label><input type="datetime-local" v-model="restForm.fecha" class="input-field"></div>
                        <div class="form-group"><label>Mesa #</label><input type="number" v-model="restForm.num_mesa" class="input-field"></div>
                        <div class="form-group"><label>Personas</label><input type="number" v-model="restForm.tamano_mesa" class="input-field"></div>
                    </div>
                    <button class="btn-add full-width mt-2" @click="saveRestReservation">Reservar Mesa</button>
                </div>
                <div class="current-list">
                    <h6>Mesas Reservadas:</h6>
                    <ul>
                        <li v-for="(item, i) in currentConfig.restaurantes" :key="i">
                            <div>
                                <strong>🍽️ {{ item.nombre_restaurante }}</strong> (Mesa: {{ item.mesa }})
                                <br><small>📅 {{ item.fecha }}</small>
                            </div>
                            <button class="btn-remove" @click="deleteElement('restaurante', item)" title="Quitar">✕</button>
                        </li>
                    </ul>
                </div>
            </div>

        </div>
      </div>
    </div>

    <div v-if="showDetailModal" class="modal-backdrop" @click.self="showDetailModal=false">
      <div class="modal-window">
        <div class="modal-header">
           <h3>🔍 Detalle del Paquete</h3>
           <button class="close-icon" @click="showDetailModal=false">✕</button>
        </div>
        <div v-if="detailData" class="modal-body detail-view">
             <div class="detail-summary">
                 <h2 class="detail-title">{{ detailData.info.paq_tur_nombre }}</h2>
                 <div class="badges-row">
                     <div class="price-badge main">💵 ${{ formatCurrency(detailData.info.paq_tur_monto_total) }}</div>
                     <div class="price-badge secondary">🌟 {{ detailData.info.paq_tur_costo_en_millas }} Millas</div>
                 </div>
             </div>
             
             <div v-if="detailData.traslados?.length" class="detail-block">
                <h5>✈️ Traslados</h5>
                <div v-for="(t, i) in detailData.traslados" :key="i" class="detail-item">
                    <span class="route-arrow">➔</span> {{ t.origen }} a {{ t.destino }} <small>({{ t.tipo }})</small>
                </div>
             </div>

             <div v-if="detailData.alojamientos?.length" class="detail-block">
                <h5>🏨 Alojamientos</h5>
                <div v-for="(a, i) in detailData.alojamientos" :key="i" class="detail-item">
                    <strong>{{ a.nombre_hotel }}</strong> ({{ a.habitacion }})
                    <br><small class="text-muted">{{ a.entrada }} - {{ a.salida }}</small>
                </div>
             </div>

             <div v-if="detailData.servicios_genericos?.length" class="detail-block">
                <h5>🎫 Actividades</h5>
                <div v-for="(s, i) in detailData.servicios_genericos" :key="i" class="detail-item">
                    {{ s.cantidad }}x {{ s.nombre }}
                </div>
             </div>

             <div v-if="detailData.reglas?.length" class="detail-block">
                 <h5>⚠️ Condiciones</h5>
                 <div class="tags-container">
                     <span v-for="(r, i) in detailData.reglas" :key="i" class="rule-tag">{{ r.atributo }} {{ r.operador }} {{ r.valor }}</span>
                 </div>
             </div>
        </div>
        <div v-else class="modal-body loading-text">
            <i class="fa-solid fa-circle-notch fa-spin"></i> Cargando información...
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';

// --- CONFIGURACIÓN Y CONSTANTES ---
// Lista de Atributos permitidos en BD para evitar errores de escritura
const attributeOptions = [
    { label: '🎂 Edad del Viajero', value: 'viajero_edad' },
    { label: '🌟 Millas Acumuladas', value: 'usuario_millas' },
    { label: '📍 Ubicación (Estado)', value: 'usuario_estado' },
    { label: '🌍 Nacionalidad', value: 'viajero_nacionalidad' },
    { label: '💍 Estado Civil', value: 'viajero_estado_civil' },
    { label: '👥 Cantidad de Personas', value: 'reserva_cantidad' },
    { label: '📅 Mes del Viaje', value: 'fecha_mes' }
];

// --- ESTADOS ---
const packages = ref([]);
const showModal = ref(false);
const showConfigModal = ref(false);
const showDetailModal = ref(false);
const showRuleManager = ref(false); // Estado para el modal de reglas
const isEditing = ref(false);
const isEditingRule = ref(false); // Estado para edición de reglas
const activeTab = ref('reglas');
const selectedPackage = ref(null);
const detailData = ref(null);
const currentConfig = ref({});

// Listas de catálogo
const listRules = ref([]);
const listGenericServices = ref([]);
const listRooms = ref([]);
const listRestaurants = ref([]);
const listTransfers = ref([]);

// Filtros y selecciones
const searchTransfer = ref('');
const selectedRuleId = ref('');
const selectedServiceId = ref('');
const serviceQty = ref(1);
const selectedTransferId = ref('');

// Formularios
const form = reactive({ id: null, nombre: '', descripcion: '', monto_total: 0, monto_subtotal: 0, costo_millas: 0 });
const ruleForm = reactive({ id: null, atributo: '', operador: '=', valor: '' }); // Formulario para crear/editar regla
const roomForm = reactive({ id_habitacion: '', fecha_inicio: '', fecha_fin: '' });
const restForm = reactive({ id_restaurante: '', fecha: '', num_mesa: '', tamano_mesa: '' });

const formatCurrency = (val) => Number(val).toFixed(2);

const filteredTransfers = computed(() => {
    if (!searchTransfer.value) return listTransfers.value;
    const term = searchTransfer.value.toLowerCase();
    
    return listTransfers.value.filter(t => {
        // Validación de seguridad (Optional Chaining ?.)
        // Buscamos en 'descripcion' (que tiene la fecha) y en 'nombre' (origen->destino)
        const desc = t.descripcion ? t.descripcion.toLowerCase() : '';
        const nom = t.nombre ? t.nombre.toLowerCase() : '';
        
        return desc.includes(term) || nom.includes(term);
    });
});

// --- FETCHING API ---
const fetchPackages = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/paquetes');
        const data = await res.json();
        if(data.success) packages.value = data.data;
    } catch(e) { console.error(e); }
};

const loadCatalogs = async () => {
    try {
        // Cargar Reglas (siempre necesario para el manager y config)
        fetch('http://localhost:3000/api/reglas')
            .then(r => r.json())
            .then(d => { if(d.success) listRules.value = d.data; });

        // Cargar lo demás solo si estamos en config de paquete
        if (showConfigModal.value) {
            const [r2, r3, r4, r5] = await Promise.all([
                fetch('http://localhost:3000/api/opciones/servicios').then(r => r.json()),
                fetch('http://localhost:3000/api/opciones/habitaciones').then(r => r.json()),
                fetch('http://localhost:3000/api/opciones/restaurantes').then(r => r.json()),
                fetch('http://localhost:3000/api/traslados-disponibles').then(r => r.json())
            ]);
            if(r2.success) listGenericServices.value = r2.data;
            if(r3.success) listRooms.value = r3.data;
            if(r4.success) listRestaurants.value = r4.data;
            if(r5.success) listTransfers.value = r5.data; 
        }
    } catch(e) { console.error(e); }
};

const refreshConfigData = async (id) => {
    try {
        const res = await fetch(`http://localhost:3000/api/paquetes/${id}/detalles`);
        const data = await res.json();
        if(data.success) currentConfig.value = data.data;
    } catch(e) { console.error(e); }
};

// --- CRUD DE REGLAS (GESTOR) ---
const openRuleManager = () => {
    loadCatalogs(); 
    isEditingRule.value = false;
    Object.assign(ruleForm, { id: null, atributo: '', operador: '=', valor: '' });
    showRuleManager.value = true;
};

const saveRule = async () => {
    if(!ruleForm.atributo || !ruleForm.valor) return alert("Complete los campos");
    
    const url = isEditingRule.value 
        ? `http://localhost:3000/api/reglas/${ruleForm.id}` 
        : 'http://localhost:3000/api/reglas';
    
    const method = isEditingRule.value ? 'PUT' : 'POST';

    try {
        const res = await fetch(url, {
            method: method,
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(ruleForm)
        });
        const data = await res.json();
        if(data.success) {
            alert(isEditingRule.value ? 'Regla actualizada' : 'Regla creada');
            loadCatalogs(); // Recargar lista
            cancelEditRule();
        } else {
            alert(data.message);
        }
    } catch(e) { console.error(e); }
};

const editRule = (rule) => {
    isEditingRule.value = true;
    Object.assign(ruleForm, { 
        id: rule.reg_paq_codigo, 
        atributo: rule.reg_paq_atributo, 
        operador: rule.reg_paq_operador, 
        valor: rule.reg_paq_valor 
    });
};

const deleteRuleDefinition = async (id) => {
    if(!confirm('¿Eliminar definición de regla? Si está en uso por algún paquete, fallará.')) return;
    try {
        const res = await fetch(`http://localhost:3000/api/reglas/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if(data.success) {
            loadCatalogs();
        } else {
            alert(data.message);
        }
    } catch(e) { console.error(e); }
};

const cancelEditRule = () => {
    isEditingRule.value = false;
    Object.assign(ruleForm, { id: null, atributo: '', operador: '=', valor: '' });
};

// --- GESTIÓN DE PAQUETES Y CONTENIDO ---

const deleteElement = async (type, item) => {
    if(!confirm('¿Quitar este elemento del paquete?')) return;
    
    let idElemento = null;
    let fecha = null;
    let extra = null;

    if(type === 'regla') idElemento = item.cod_regla;
    if(type === 'servicio') idElemento = item.cod_servicio;
    if(type === 'traslado') idElemento = item.cod_traslado;
    if(type === 'habitacion') { idElemento = item.num_habitacion; fecha = item.fecha_inicio; }
    if(type === 'restaurante') { idElemento = item.cod_restaurante; fecha = item.fecha_reserva; extra = item.num_mesa_id; }

    try {
        const res = await fetch('http://localhost:3000/api/paquetes/eliminar-elemento', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                tipo: type,
                id_paquete: selectedPackage.value.paq_tur_codigo,
                id_elemento: idElemento,
                fecha_inicio: fecha,
                extra_id: extra
            })
        });
        const data = await res.json();
        if(data.success) {
            await refreshConfigData(selectedPackage.value.paq_tur_codigo);
        } else {
            alert(data.message);
        }
    } catch(e) { console.error(e); }
};

const assignItem = async (type) => {
    let url = '', payload = {};
    const pkgId = selectedPackage.value.paq_tur_codigo;

    if (type === 'regla') { 
        if(!selectedRuleId.value) return alert("Seleccione una regla");
        url = 'http://localhost:3000/api/asignar-regla'; 
        payload = { fk_paq_tur_codigo: pkgId, fk_reg_paq_codigo: selectedRuleId.value }; 
    } 
    else if (type === 'servicio') { 
        if(!selectedServiceId.value) return alert("Seleccione un servicio");
        url = 'http://localhost:3000/api/asignar/servicio-generico'; 
        payload = { id_paquete: pkgId, id_servicio: selectedServiceId.value, cantidad: serviceQty.value }; 
    }
    else if (type === 'traslado') { 
        if(!selectedTransferId.value) return alert("Seleccione un traslado");
        url = 'http://localhost:3000/api/asignar-traslado'; 
        payload = { id_paquete: pkgId, id_traslado: selectedTransferId.value }; 
    }

    try {
        const res = await fetch(url, { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload) });
        const data = await res.json();
        if(data.success) {
            alert("Agregado exitosamente");
            await refreshConfigData(pkgId);
        } else alert(data.message);
    } catch(e) { console.error(e); }
};

const savePackage = async () => {
    try {
        const url = isEditing.value ? `http://localhost:3000/api/paquetes/${form.id}` : 'http://localhost:3000/api/paquetes';
        const method = isEditing.value ? 'PUT' : 'POST';
        const res = await fetch(url, { method, headers: {'Content-Type': 'application/json'}, body: JSON.stringify(form) });
        const data = await res.json();
        if(data.success) { showModal.value=false; fetchPackages(); }
    } catch(e) { console.error(e); }
};

const saveRoomReservation = async () => {
    if(!roomForm.id_habitacion || !roomForm.fecha_inicio || !roomForm.fecha_fin) {
        return alert("Por favor complete los datos de la reserva (Habitación y Fechas).");
    }
    const room = listRooms.value.find(r => r.id === roomForm.id_habitacion);
    try {
        const res = await fetch('http://localhost:3000/api/reservar/habitacion', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                id_paquete: selectedPackage.value.paq_tur_codigo,
                id_habitacion: roomForm.id_habitacion,
                fecha_inicio: roomForm.fecha_inicio,
                fecha_fin: roomForm.fecha_fin,
                costo: room ? room.costo : 0
            })
        });
        const data = await res.json();
        if(data.success) { 
            alert("Alojamiento reservado exitosamente"); 
            await refreshConfigData(selectedPackage.value.paq_tur_codigo); 
            Object.assign(roomForm, { id_habitacion: '', fecha_inicio: '', fecha_fin: '' });
        } else { alert(data.message); }
    } catch(e) { console.error(e); }
};

const saveRestReservation = async () => {
    if(!restForm.id_restaurante || !restForm.fecha) {
        return alert("Faltan datos obligatorios (Restaurante y Fecha).");
    }
    try {
        const res = await fetch('http://localhost:3000/api/reservar/restaurante', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                id_paquete: selectedPackage.value.paq_tur_codigo,
                id_restaurante: restForm.id_restaurante,
                fecha: restForm.fecha,
                num_mesa: restForm.num_mesa || 1, 
                tamano_mesa: restForm.tamano_mesa || 2
            })
        });
        const data = await res.json();
        if(data.success) { 
            alert("Mesa reservada exitosamente"); 
            await refreshConfigData(selectedPackage.value.paq_tur_codigo);
            Object.assign(restForm, { id_restaurante: '', fecha: '', num_mesa: '', tamano_mesa: '' });
        } else { alert(data.message); }
    } catch(e) { console.error(e); }
};

const deletePackage = async (id) => {
    if(!confirm('¿Estás seguro de eliminar este paquete permanentemente?')) return;
    try {
        const res = await fetch(`http://localhost:3000/api/paquetes/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if(data.success) { alert('Paquete eliminado'); fetchPackages(); } 
        else { alert('Error: ' + data.message); }
    } catch(e) { console.error(e); }
};

const openDetailsModal = async (id) => {
    detailData.value = null; showDetailModal.value = true;
    try {
        const res = await fetch(`http://localhost:3000/api/paquetes/${id}/detalles`);
        const data = await res.json();
        if(data.success) detailData.value = data.data;
    } catch(e) { console.error(e); }
};

const openCreateModal = () => { isEditing.value=false; Object.assign(form, {nombre:'', descripcion:'', monto_total:0, monto_subtotal:0, costo_millas:0}); showModal.value=true; };
const openEditModal = (p) => { isEditing.value=true; Object.assign(form, {id:p.paq_tur_codigo, nombre:p.paq_tur_nombre, descripcion:p.paq_tur_descripcion, monto_total:p.paq_tur_monto_total, monto_subtotal:p.paq_tur_monto_subtotal, costo_millas:p.paq_tur_costo_en_millas}); showModal.value=true; };
const openConfigModal = (p) => { 
    selectedPackage.value=p; 
    showConfigModal.value=true;
    // Cargar catálogos solo al abrir configuración
    loadCatalogs(); 
    refreshConfigData(p.paq_tur_codigo); 
};

onMounted(() => fetchPackages());
</script>

<style scoped>
/* ESTILOS GENERALES */
.container-fluid { padding: 30px; background-color: #f8fafc; min-height: 100vh; font-family: 'Segoe UI', sans-serif; }
.header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.header-actions h2 { color: #1e293b; margin: 0; font-weight: 700; }
.subtitle { color: #64748b; margin: 0; font-size: 0.9rem; }

.btn-group-header { display: flex; gap: 10px; }

/* TABLA */
.table-card { background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); overflow: hidden; }
.styled-table { width: 100%; border-collapse: collapse; }
.styled-table th { background: #f1f5f9; color: #475569; padding: 16px; font-size: 0.85rem; text-transform: uppercase; font-weight: 600; text-align: left; }
.styled-table td { padding: 16px; border-bottom: 1px solid #e2e8f0; color: #334155; }
.id-tag { color: #64748b; font-weight: 600; font-size: 0.85rem; }
.font-bold { font-weight: 600; color: #0f172a; }
.amount-text { font-family: 'Consolas', monospace; color: #059669; font-weight: 700; }
.miles-tag { background: #eff6ff; color: #2563eb; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }

/* BOTONES */
.btn-main { background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; display: flex; gap: 8px; align-items: center; }
.btn-main:hover { background: #1d4ed8; }
.btn-secondary { background: #e2e8f0; color: #475569; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; display: flex; gap: 8px; align-items: center; }
.btn-secondary:hover { background: #cbd5e1; }
.small { padding: 0 15px; height: 38px; }

.action-group { display: flex; gap: 5px; justify-content: center; }
.action-btn { width: 32px; height: 32px; border: none; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; color: #475569; background: transparent; }
.action-btn:hover { background: #f1f5f9; color: #2563eb; }
.btn-delete:hover { color: #dc2626; background: #fee2e2; }

/* MODALES */
.modal-backdrop { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-window { background: white; border-radius: 16px; width: 95%; max-width: 500px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); display: flex; flex-direction: column; max-height: 90vh; animation: slideUp 0.3s ease-out; }
.modal-window.large { max-width: 850px; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

.modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
.modal-header h3 { margin: 0; font-size: 1.25rem; color: #0f172a; }
.close-icon { background: none; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer; }
.modal-body { padding: 24px; overflow-y: auto; }
.modal-footer { padding: 20px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; background: #f8fafc; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px; }

/* FORMULARIOS */
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #475569; font-size: 0.85rem; }
.input-field { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; background: white; transition: border 0.2s; }
.input-field:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
.row-inputs { display: flex; gap: 15px; }
.row-inputs .form-group { flex: 1; }
.input-group { display: flex; gap: 10px; }
.input-group-row { display: flex; gap: 10px; align-items: flex-end; }
.flex-grow { flex: 1; }
.qty-input { width: 80px; }
.search-box { margin-bottom: 10px; border-color: #93c5fd; background: #eff6ff; }

.btn-add { background: #10b981; color: white; border: none; padding: 0 15px; height: 38px; border-radius: 6px; font-weight: 600; cursor: pointer; white-space: nowrap; }
.btn-add:hover { background: #059669; }
.btn-container { display: flex; gap: 5px; }

/* TABS */
.tabs-header { display: flex; padding: 0 24px; border-bottom: 1px solid #e2e8f0; gap: 20px; overflow-x: auto; }
.tabs-header button { background: none; border: none; padding: 16px 0; color: #64748b; font-weight: 600; cursor: pointer; border-bottom: 2px solid transparent; white-space: nowrap; display: flex; gap: 8px; align-items: center; }
.tabs-header button:hover { color: #3b82f6; }
.tabs-header button.active { color: #2563eb; border-bottom-color: #2563eb; }

/* LISTAS INTERNAS */
.assign-form { background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 15px; }
.current-list { margin-top: 10px; }
.current-list h6 { margin: 0 0 10px 0; color: #475569; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.5px; }
.current-list ul { list-style: none; padding: 0; margin: 0; }
.current-list li { background: white; border: 1px solid #e2e8f0; padding: 10px 12px; margin-bottom: 8px; border-radius: 6px; display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem; color: #334155; }
.btn-remove { width: 24px; height: 24px; border-radius: 50%; border: 1px solid #fecaca; background: #fef2f2; color: #dc2626; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 0.7rem; transition: 0.2s; }
.btn-remove:hover { background: #dc2626; color: white; }

/* BADGES Y ETIQUETAS */
.badge-attr { background-color: #e0f2fe; color: #0369a1; padding: 4px 8px; border-radius: 4px; font-weight: 600; font-size: 0.85rem; }
.badge-attr-small { background-color: #f1f5f9; color: #475569; padding: 2px 6px; border-radius: 4px; font-weight: 700; font-size: 0.75rem; margin-right: 5px; text-transform: uppercase; }
.hint-text { margin-top: 8px; color: #64748b; font-size: 0.85rem; font-style: italic; display: flex; gap: 5px; align-items: center; }

/* DETALLES VISUALES */
.detail-summary { text-align: center; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; }
.detail-title { margin: 0 0 5px 0; color: #0f172a; font-size: 1.5rem; }
.badges-row { display: flex; justify-content: center; gap: 10px; margin-top: 10px; }
.price-badge { padding: 6px 12px; border-radius: 20px; font-weight: 700; font-size: 0.9rem; }
.price-badge.main { background: #dcfce7; color: #166534; }
.price-badge.secondary { background: #f1f5f9; color: #475569; }
.detail-block { margin-bottom: 20px; }
.detail-block h5 { margin: 0 0 10px 0; color: #64748b; font-size: 0.85rem; text-transform: uppercase; border-left: 3px solid #3b82f6; padding-left: 8px; }
.detail-item { background: #f8fafc; padding: 10px; border-radius: 6px; margin-bottom: 5px; font-size: 0.9rem; color: #334155; }
.rule-tag { display: inline-block; background: #fff7ed; border: 1px solid #fed7aa; color: #c2410c; padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; margin-right: 5px; margin-bottom: 5px; }
</style>