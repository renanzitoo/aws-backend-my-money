const express = require('express');
const authMiddleware = require('../middlewares/auth.middleware');
const {
  createUrl,
  getUserUrls,
  getUrlById,
  updateUrl,
  deleteUrl,
  getUrlAnalytics,
} = require('../controllers/url.controller');

const router = express.Router();

// Protected routes (auth required)
router.post('/', authMiddleware, createUrl);
router.get('/', authMiddleware, getUserUrls);
router.get('/urls/:id', authMiddleware, getUrlById);
router.put('/urls/:id', authMiddleware, updateUrl);
router.delete('/urls/:id', authMiddleware, deleteUrl);
router.get('/urls/:id/analytics', authMiddleware, getUrlAnalytics);

module.exports = router;
