import React from "react";
import {Card, CardContent, Chip, Stack, Typography,} from "@mui/material";
import dayjs from "dayjs";

const actionLabels = {
    created: "Document created",
    ocr_started: "OCR started",
    ocr_failed: "OCR failed",
    ocr_succeeded: "OCR succeeded",
    nlp_started: "NLP started",
    nlp_failed: "NLP failed",
    nlp_succeeded: "NLP succeeded",
    approved: "Approved",
    rejected: "Rejected",
    edited: "Edited",
};

const actionColors = {
    created: "primary",
    ocr_started: "info",
    ocr_failed: "error",
    ocr_succeeded: "success",
    nlp_started: "info",
    nlp_failed: "error",
    nlp_succeeded: "success",
    approved: "success",
    rejected: "error",
    edited: "warning",
};

const HistoryLog = ({historyLog}) => {
    const {action, created_at} = historyLog;

    return (
        <Card variant="outlined" sx={{mb: 2}}>
            <CardContent sx={{padding: '12px !important'}}>
                <Stack direction="row" spacing={2} alignItems="center" justifyContent="space-between">
                    <Chip
                        label={actionLabels[action] || action}
                        color={actionColors[action] || "default"}
                        clickable={false}
                        onClick={() => 0}
                        variant="filled"
                    />
                    <Typography variant="body2" color="text.secondary">
                        {dayjs(created_at).format("YYYY-MM-DD HH:mm")}
                    </Typography>
                </Stack>
            </CardContent>
        </Card>
    );
};

export default HistoryLog;
