import { createRouter, createWebHistory } from 'vue-router';
import Login from '@/views/general/Login.vue';
import SelfRegisterClient from '@/views/client/SelfRegisterClient.vue';
import ClientDashboard from '@/views/client/ClientDashboard.vue';
import AdminDashboard from '@/views/admin/AdminDashboard.vue';


const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path:'/login',
            name:'login',
            component: Login
        },
        {
            path:'/client/register/',
            name:'client-register',
            component:SelfRegisterClient
        },
        {
            path:'/client/dashboard',
            name:'client-dashboard',
            component:ClientDashboard
        },
        {
            path:'/admin/dashboard',
            name:'admin-dashboard',
            component:AdminDashboard
        }
    ]
})

export default router;