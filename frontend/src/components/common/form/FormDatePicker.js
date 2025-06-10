import React from 'react';
import TextField from '@mui/material/TextField';
import {DatePicker} from "@mui/x-date-pickers";
import dayjs from "dayjs";

const DatePickerInput = ({
                             name, label, formik,
                             referenceDate = dayjs(),
                         }) => {
    const {
        values,
        errors,
        touched,
        setFieldValue,
        setFieldTouched
    } = formik;

    const fieldError = touched[name] && errors[name];
    const value = values[name] || null;

    return (
        <DatePicker
            sx={{mb: 2}}
            label={label}
            value={value}
            referenceDate={referenceDate}
            onChange={(newValue) => setFieldValue(name, newValue)}
            onAccept={() => setFieldTouched(name, true)}
            onBlur={() => setFieldTouched(name, true)}
            renderInput={(params) => (
                <TextField
                    {...params}
                    fullWidth
                    error={Boolean(fieldError)}
                    helperText={fieldError}
                    sx={{mb: 2}}
                />
            )}
        />
    );
};

export default DatePickerInput;