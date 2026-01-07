import { createRouter, createWebHistory } from 'vue-router';

// Imports de componentes
import Login from '@/views/general/Login.vue';
import SelfRegisterClient from '@/views/client/SelfRegisterClient.vue';
import ClientDashboard from '@/views/client/ClientDashboard.vue';
import AdminDashboard from '@/views/admin/AdminDashboard.vue';
import ProviderAirlineDashboard from '@/views/provider/ProviderAirlineDashboard.vue';
import NotDevelopedYet from '@/views/general/NotDevelopedYet.vue';
import HomePage from '@/views/general/HomePage.vue';
import Cart from '@/views/client/Cart.vue';
import SearchResults from '@/views/general/SearchResults.vue';
import AdminReports from '@/views/admin/AdminReports.vue';

// IMPORTANTE: Aquí estás importando AdminGestionPromociones.vue
// Asegúrate de que tu archivo en la carpeta views/admin se llame EXACTAMENTE así.
import Promotions from '@/views/admin/AdminGestionPromociones.vue'; 

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/home',
            name: 'home',
            component: HomePage
        },
        {
            path: '/',
            name: 'login',
            component: Login
        },
        {
            path: '/client/register/',
            name: 'client-register',
            component: SelfRegisterClient
        },
        {
            path: '/client/dashboard',
            name: 'client-dashboard',
            component: ClientDashboard
        },
        {
            path: '/admin/dashboard',
            name: 'admin-dashboard',
            component: AdminDashboard
        },
        {
            path: '/providers/airlines/dashboard',
            name: 'providers-airlines-dashboard',
            component: ProviderAirlineDashboard
        },
        {
            path: '/not-developed',
            name: 'NotDeveloped',
            component: NotDevelopedYet
        },
        { 
            path: '/results', 
            name: 'results', 
            component: SearchResults,
            props: route => ({ query: route.query }) 
        },
        
        // --- RUTAS DE PROMOCIONES ---
        {
            path:'/admin/promotions',
            name:'admin-promotions',
            component:Promotions,
        },
        {
            path: '/admin/reports',
            name: 'admin-reports',
            component: AdminReports
        },
        // -------------------------------------------
        {
            path: '/client/cart',
            name:'cart',
            component:Cart
        }
    ]
})

export default router;