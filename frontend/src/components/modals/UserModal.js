import React from 'react';
import Modal from '../common/Modal';
import {useFormik} from 'formik';
import * as Yup from 'yup';
import FormInput from "../common/form/FormInput";
import FormSelect from "../common/form/FormSelect";
import FormCheckbox from "../common/form/FormCheckbox";
import Box from "@mui/material/Box";
import {ROLES} from "../../utils/constants";
import * as _ from 'lodash';

const validationSchema = Yup.object({
    email: Yup.string()
        .email('Invalid email address')
        .required('Email is required'),
    role: Yup.string()
        .required('Role is required'),
    change_password: Yup.boolean(),
    password: Yup.string()
        .min(8, 'Password must be at least 8 characters')
        .when(['id', 'change_password'], {
            is: (id, change_password) => id === undefined || change_password === true,
            then: schema =>
                schema.required('Password is required'),
            otherwise: schema =>
                schema.notRequired(),
        }),
    password_confirmation: Yup.string()
        .oneOf([Yup.ref('password'), null], 'Passwords must match')
        .when(['id', 'change_password'], {
            is: (id, change_password) => id === undefined || change_password === true,
            then: schema =>
                schema.required('Password confirmation is required'),
            otherwise: schema =>
                schema.notRequired(),
        }),
});

const UserModal = ({onClose, user, onSave}) => {
    const isNewUser = !user?.id;

    const formik = useFormik({
        initialValues: {
            id: user?.id || '',
            email: user?.email || '',
            role: user?.role || 'user',
            password: ''
        },
        validationSchema,
        enableReinitialize: true,
        onSubmit: (values) => {
            if (!isNewUser && !values.change_password) {
                delete values.password;
            }

            onSave(values);
            onClose();
        }
    });

    return (
        <Modal
            open
            onClose={onClose}
            title={isNewUser ? 'Add New User' : 'Edit User'}
            onSubmit={formik.handleSubmit}
            submitDisabled={formik.isSubmitting || !formik.isValid}
        >
            <Box component="form" onSubmit={formik.handleSubmit} sx={{mt: 2}}>
                <FormInput name="email" label="Email" type="email" formik={formik}/>
                <FormSelect
                    name="role"
                    label="Role"
                    options={
                        Object.values(ROLES).map(role => ({value: role, label: _.upperFirst(role)}))
                    }
                    formik={formik}
                />
                {!isNewUser && <FormCheckbox name="change_password" label="Change password" formik={formik}/>}
                {(isNewUser || formik.values.change_password) && <>
                    <FormInput name="password" label="Password" type="password" formik={formik}/>
                    <FormInput name="password_confirmation" label="Password confirmation" type="password"
                               formik={formik}/>
                </>}
            </Box>
        </Modal>
    );
};

export default UserModal;
