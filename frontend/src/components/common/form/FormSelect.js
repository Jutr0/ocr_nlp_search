import {FormControl, FormHelperText, InputLabel, MenuItem, Select} from "@mui/material";

const FormSelect = ({name, label, options = [], formik}) => {
    const {
        values,
        errors,
        touched,
        setFieldValue,
        handleBlur
    } = formik;

    const fieldError = touched[name] && errors[name];

    return (
        <FormControl fullWidth error={Boolean(fieldError)} sx={{mb: 2}}>
            <InputLabel id={`${name}-label`}>{label}</InputLabel>
            <Select
                labelId={`${name}-label`}
                id={name}
                name={name}
                value={values[name] || ''}
                label={label}
                onChange={e => setFieldValue(name, e.target.value)}
                onBlur={handleBlur}
                variant="outlined"
            >
                {options.map(opt => (
                    <MenuItem key={opt.value} value={opt.value}>
                        {opt.label}
                    </MenuItem>
                ))}
            </Select>
            {fieldError && (
                <FormHelperText>{errors[name]}</FormHelperText>
            )}
        </FormControl>
    );
};

export default FormSelect;