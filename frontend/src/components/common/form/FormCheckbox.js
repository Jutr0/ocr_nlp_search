// src/components/inputs/FormCheckbox.jsx
import React from 'react';
import {Checkbox, FormControl, FormControlLabel, FormHelperText} from '@mui/material';

function FormCheckbox({name, label, formik, ...props}) {
    const {
        values,
        errors,
        touched,
        setFieldValue,
        setFieldTouched
    } = formik;

    const fieldError = touched[name] && errors[name];
    const checked = Boolean(values[name]);

    const handleChange = event => {
        setFieldValue(name, event.target.checked);
        setFieldTouched(name, true);
    };

    return (
        <FormControl component="fieldset" error={Boolean(fieldError)} sx={{mb: 2}} fullWidth>
            <FormControlLabel
                control={
                    <Checkbox
                        name={name}
                        checked={checked}
                        onChange={handleChange}
                        {...props}
                    />
                }
                label={label}
            />
            {fieldError && (
                <FormHelperText>{errors[name]}</FormHelperText>
            )}
        </FormControl>
    );
}

export default FormCheckbox;