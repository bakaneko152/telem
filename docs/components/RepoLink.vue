<template>
    <a
        :href="'https://github.com/bakaneko152/telem/blob/master/src/telem/' + path"
        target="_blank"
        style="float: right; font-size: 16px;"
    >{{ label || 'Source' }}</a>
</template>

<script setup>
import { defineProps } from 'vue';

const props = defineProps({
    path: {
        type: String,
        required: true
    },
    label: {
        type: String
    }
});
</script>
