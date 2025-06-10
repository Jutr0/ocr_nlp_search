import React, {createContext, useEffect, useState} from 'react';
import {get, save} from "../utils/actionsBuilder";
import axios from "axios";

export const AuthContext = createContext();

const AuthProvider = ({children}) => {
    const [token, setToken] = useState(() => localStorage.getItem('token'));
    const [currentUser, setCurrentUser] = useState(null);
    const actions = {
        getUser: () => get('/profile/me'),
        signIn: (credentials) => axios.request({
            url: '/users/sign_in', method: 'POST',
            data: {
                user: credentials
            }
        }),
        signUp: (credentials) =>  axios.request({
            url: '/users', method: 'POST',
            data: {
                user: credentials
            }
        }),
        signOut: () => save('/users/sign_out', 'DELETE')
    }

    useEffect(() => {
        if (token) {
            localStorage.setItem('token', token);
            getUser();
        } else {
            localStorage.removeItem('token');
            setCurrentUser(null);
        }
    }, [token]);

    const getUser = async () => {
        try {
            const user = await actions.getUser();
            setCurrentUser(user);
        } catch {
            logout();
        }
    };

    const login = async (credentials) => {
        const response = await actions.signIn(credentials);
        setToken(response.headers.authorization.split(' ')[1]);
        setCurrentUser(response.data.user);
    };

    const register = async (credentials) => {
        const response = await actions.signUp(credentials);
        setToken(response.headers.authorization.split(' ')[1]);
        setCurrentUser(response.data.user);
    };

    const logout = async () => {
        await actions.signOut();
        setToken(null);
    };
    return (
        <AuthContext.Provider value={{currentUser, login, logout, register}}>
            {children}
        </AuthContext.Provider>
    );
}

export default AuthProvider;