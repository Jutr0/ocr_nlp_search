import React from 'react';
import {
    Box,
    CircularProgress,
    Paper,
    Table as MUITable,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TablePagination,
    TableRow,
    Typography
} from '@mui/material';
import Button from './Button';

const Table = ({
                   columns = [],
                   data = [],
                   loading = false,
                   onRowClick,
                   pagination = false,
                   page = 0,
                   rowsPerPage = 10,
                   onPageChange,
                   onRowsPerPageChange,
                   onEdit,
                   onDelete
               }) => {
    const paginatedRows = pagination
        ? data.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
        : data;

    const hasActions = onEdit || onDelete;
    const effectiveColSpan = hasActions ? columns.length + 1 : columns.length;

    const handleActionClick = (e, action, row) => {
        e.stopPropagation();
        action(row);
    };

    return (
        <Paper sx={{width: '100%', overflow: 'hidden'}}>
            <TableContainer>
                <MUITable>
                    <TableHead>
                        <TableRow>
                            {columns.map((col) => (
                                <TableCell key={col.field} align={col.align || 'left'}>
                                    {col.headerName}
                                </TableCell>
                            ))}
                            {hasActions && (
                                <TableCell align="right">Actions</TableCell>
                            )}
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={effectiveColSpan}>
                                    <Box display="flex" justifyContent="center" py={3}>
                                        <CircularProgress/>
                                    </Box>
                                </TableCell>
                            </TableRow>
                        ) : paginatedRows.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={effectiveColSpan}>
                                    <Box display="flex" justifyContent="center" py={3}>
                                        <Typography variant="body2" color="text.secondary">
                                            Not found
                                        </Typography>
                                    </Box>
                                </TableCell>
                            </TableRow>
                        ) : (
                            paginatedRows.map((row, idx) => (
                                <TableRow
                                    key={row.id || idx}
                                    hover
                                    onClick={() => onRowClick?.(row)}
                                    sx={{cursor: onRowClick ? 'pointer' : 'default'}}
                                >
                                    {columns.map((col) => (
                                        <TableCell key={col.field} align={col.align || 'left'}>
                                            {col.render ? col.render(row[col.field], row) : row[col.field]}
                                        </TableCell>
                                    ))}
                                    {hasActions && (
                                        <TableCell align="right">
                                            <Box sx={{display: 'flex', justifyContent: 'flex-end', gap: 1}}>
                                                {onEdit && (
                                                    <Button
                                                        size="small"
                                                        color="primary"
                                                        onClick={(e) => handleActionClick(e, () => onEdit(row), row)}
                                                    >
                                                        Edit
                                                    </Button>
                                                )}
                                                {onDelete && (
                                                    <Button
                                                        size="small"
                                                        variant="contained"
                                                        color="error"
                                                        onClick={(e) => handleActionClick(e, () => onDelete(row.id), row)}
                                                    >
                                                        Delete
                                                    </Button>
                                                )}
                                            </Box>
                                        </TableCell>
                                    )}
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </MUITable>
            </TableContainer>

            {pagination && (
                <TablePagination
                    component="div"
                    count={data.length}
                    page={page}
                    rowsPerPage={rowsPerPage}
                    onPageChange={onPageChange}
                    onRowsPerPageChange={onRowsPerPageChange}
                    rowsPerPageOptions={[5, 10, 25]}
                />
            )}
        </Paper>
    );
};

export default Table;