import React from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Typography,
  Box
} from '@mui/material';
import Button from './Button';

const Modal = ({
  open,
  onClose,
  title,
  children,
  actions,
  submitText = 'Save',
  onSubmit,
  submitDisabled = false,
  cancelText = 'Cancel',
  size = 'sm',
  fullWidth = true,
  hideActions = false
}) => {
  const handleSubmit = (e) => {
    e.preventDefault();
    if (onSubmit) {
      onSubmit();
    }
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth={size}
      fullWidth={fullWidth}
      aria-labelledby="modal-title"
    >
      <DialogTitle id="modal-title">
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Typography variant="h6">{title}</Typography>
        </Box>
      </DialogTitle>
      
      <DialogContent dividers>
        {children}
      </DialogContent>
      
      {!hideActions && (
        <DialogActions sx={{ px: 3, py: 2 }}>
          {actions ? (
            actions
          ) : (
            <>
              <Button
                variant="outlined"
                onClick={onClose}
                sx={{ mr: 1 }}
              >
                {cancelText}
              </Button>
              <Button
                variant="contained"
                color="primary"
                onClick={handleSubmit}
                disabled={submitDisabled}
              >
                {submitText}
              </Button>
            </>
          )}
        </DialogActions>
      )}
    </Dialog>
  );
};

export default Modal;
