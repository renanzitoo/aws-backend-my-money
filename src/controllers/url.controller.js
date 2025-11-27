const prisma = require('../utils/prisma');
const { nanoid } = require('nanoid');

// Validate and normalize URL
const isValidUrl = (url) => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

// Generate a unique short code
const generateShortCode = async () => {
  let shortCode;
  let exists = true;
  
  while (exists) {
    shortCode = nanoid(6);
    const url = await prisma.shortenedUrl.findUnique({
      where: { shortCode }
    });
    exists = !!url;
  }
  
  return shortCode;
};

// Create a shortened URL
const createUrl = async (req, res) => {
  const { originalUrl, title, description, customCode, expiresAt } = req.body;
  const userId = req.userId;

  if (!originalUrl) {
    return res.status(400).json({ error: 'Original URL is required' });
  }

  if (!isValidUrl(originalUrl)) {
    return res.status(400).json({ error: 'Invalid URL format' });
  }

  try {
    let shortCode = customCode;

    // If custom code is provided, validate it
    if (customCode) {
      if (customCode.length < 3 || customCode.length > 20) {
        return res.status(400).json({ error: 'Short code must be between 3 and 20 characters' });
      }

      const existingUrl = await prisma.shortenedUrl.findUnique({
        where: { shortCode: customCode }
      });

      if (existingUrl) {
        return res.status(400).json({ error: 'This short code is already taken' });
      }
    } else {
      // Generate a random short code
      shortCode = await generateShortCode();
    }

    const url = await prisma.shortenedUrl.create({
      data: {
        userId,
        originalUrl,
        shortCode,
        title: title || null,
        description: description || null,
        expiresAt: expiresAt ? new Date(expiresAt) : null,
      },
    });

    return res.status(201).json({
      id: url.id,
      originalUrl: url.originalUrl,
      shortCode: url.shortCode,
      shortUrl: `${process.env.BASE_URL || 'http://localhost:3000'}/${url.shortCode}`,
      title: url.title,
      description: url.description,
      clicks: url.clicks,
      expiresAt: url.expiresAt,
      createdAt: url.createdAt,
    });
  } catch (error) {
    console.error('❌ [createUrl] Database error:', {
      message: error.message,
      userId,
    });
    res.status(500).json({
      error: 'Failed to create shortened URL',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get all URLs for the authenticated user
const getUserUrls = async (req, res) => {
  const userId = req.userId;
  const { page = 1, limit = 10, sortBy = 'createdAt', order = 'desc' } = req.query;

  try {
    const skip = (page - 1) * limit;

    const urls = await prisma.shortenedUrl.findMany({
      where: { userId },
      skip,
      take: parseInt(limit),
      orderBy: { [sortBy]: order },
      include: {
        analytics: {
          select: { id: true }
        }
      }
    });

    const total = await prisma.shortenedUrl.count({
      where: { userId }
    });

    const formattedUrls = urls.map(url => ({
      id: url.id,
      originalUrl: url.originalUrl,
      shortCode: url.shortCode,
      shortUrl: `${process.env.BASE_URL || 'http://localhost:3000'}/${url.shortCode}`,
      title: url.title,
      description: url.description,
      clicks: url.clicks,
      analyticsCount: url.analytics.length,
      expiresAt: url.expiresAt,
      createdAt: url.createdAt,
      updatedAt: url.updatedAt,
    }));

    return res.status(200).json({
      urls: formattedUrls,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('❌ [getUserUrls] Database error:', {
      message: error.message,
      userId,
    });
    res.status(500).json({
      error: 'Failed to fetch URLs',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get a specific shortened URL by ID
const getUrlById = async (req, res) => {
  const { id } = req.params;
  const userId = req.userId;

  try {
    const url = await prisma.shortenedUrl.findUnique({
      where: { id: parseInt(id) },
      include: {
        analytics: {
          orderBy: { clickedAt: 'desc' },
          take: 10,
        }
      }
    });

    if (!url) {
      return res.status(404).json({ error: 'URL not found' });
    }

    // Check if user owns this URL
    if (url.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    return res.status(200).json({
      id: url.id,
      originalUrl: url.originalUrl,
      shortCode: url.shortCode,
      shortUrl: `${process.env.BASE_URL || 'http://localhost:3000'}/${url.shortCode}`,
      title: url.title,
      description: url.description,
      clicks: url.clicks,
      expiresAt: url.expiresAt,
      createdAt: url.createdAt,
      updatedAt: url.updatedAt,
      recentAnalytics: url.analytics.map(a => ({
        id: a.id,
        userAgent: a.userAgent,
        referer: a.referer,
        ipAddress: a.ipAddress,
        country: a.country,
        clickedAt: a.clickedAt,
      })),
    });
  } catch (error) {
    console.error('❌ [getUrlById] Database error:', {
      message: error.message,
      userId,
      id,
    });
    res.status(500).json({
      error: 'Failed to fetch URL',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Update a shortened URL
const updateUrl = async (req, res) => {
  const { id } = req.params;
  const { title, description, expiresAt } = req.body;
  const userId = req.userId;

  try {
    const url = await prisma.shortenedUrl.findUnique({
      where: { id: parseInt(id) }
    });

    if (!url) {
      return res.status(404).json({ error: 'URL not found' });
    }

    // Check if user owns this URL
    if (url.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const updatedUrl = await prisma.shortenedUrl.update({
      where: { id: parseInt(id) },
      data: {
        title: title !== undefined ? title : url.title,
        description: description !== undefined ? description : url.description,
        expiresAt: expiresAt !== undefined ? (expiresAt ? new Date(expiresAt) : null) : url.expiresAt,
      },
    });

    return res.status(200).json({
      id: updatedUrl.id,
      originalUrl: updatedUrl.originalUrl,
      shortCode: updatedUrl.shortCode,
      shortUrl: `${process.env.BASE_URL || 'http://localhost:3000'}/${updatedUrl.shortCode}`,
      title: updatedUrl.title,
      description: updatedUrl.description,
      clicks: updatedUrl.clicks,
      expiresAt: updatedUrl.expiresAt,
      createdAt: updatedUrl.createdAt,
      updatedAt: updatedUrl.updatedAt,
    });
  } catch (error) {
    console.error('❌ [updateUrl] Database error:', {
      message: error.message,
      userId,
      id,
    });
    res.status(500).json({
      error: 'Failed to update URL',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Delete a shortened URL
const deleteUrl = async (req, res) => {
  const { id } = req.params;
  const userId = req.userId;

  try {
    const url = await prisma.shortenedUrl.findUnique({
      where: { id: parseInt(id) }
    });

    if (!url) {
      return res.status(404).json({ error: 'URL not found' });
    }

    // Check if user owns this URL
    if (url.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    await prisma.shortenedUrl.delete({
      where: { id: parseInt(id) }
    });

    return res.status(204).send();
  } catch (error) {
    console.error('❌ [deleteUrl] Database error:', {
      message: error.message,
      userId,
      id,
    });
    res.status(500).json({
      error: 'Failed to delete URL',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Redirect to original URL (public endpoint, no auth)
const redirectUrl = async (req, res) => {
  const { shortCode } = req.params;

  try {
    const url = await prisma.shortenedUrl.findUnique({
      where: { shortCode }
    });

    if (!url) {
      return res.redirect(301, 'http://localhost:5000/err');
    }

    // Check if URL has expired
    if (url.expiresAt && new Date() > url.expiresAt) {
      return res.redirect(301, 'http://localhost:5000/err');
    }

    // Record analytics
    try {
      await prisma.urlAnalytic.create({
        data: {
          urlId: url.id,
          userAgent: req.headers['user-agent'] || null,
          referer: req.headers['referer'] || null,
          ipAddress: req.ip || req.connection.remoteAddress || null,
        },
      });

      // Increment click count
      await prisma.shortenedUrl.update({
        where: { id: url.id },
        data: { clicks: { increment: 1 } },
      });
    } catch (error) {
      console.error('❌ [redirectUrl] Failed to record analytics:', error.message);
      // Don't fail the redirect if analytics recording fails
    }

    return res.redirect(301, url.originalUrl);
  } catch (error) {
    console.error('❌ [redirectUrl] Database error:', {
      message: error.message,
      shortCode,
    });
    res.status(500).json({
      error: 'Failed to redirect',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get analytics for a URL
const getUrlAnalytics = async (req, res) => {
  const { id } = req.params;
  const userId = req.userId;
  const { page = 1, limit = 20 } = req.query;

  try {
    const url = await prisma.shortenedUrl.findUnique({
      where: { id: parseInt(id) }
    });

    if (!url) {
      return res.status(404).json({ error: 'URL not found' });
    }

    // Check if user owns this URL
    if (url.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const skip = (page - 1) * limit;

    const analytics = await prisma.urlAnalytic.findMany({
      where: { urlId: parseInt(id) },
      skip,
      take: parseInt(limit),
      orderBy: { clickedAt: 'desc' },
    });

    const total = await prisma.urlAnalytic.count({
      where: { urlId: parseInt(id) }
    });

    return res.status(200).json({
      analytics: analytics.map(a => ({
        id: a.id,
        userAgent: a.userAgent,
        referer: a.referer,
        ipAddress: a.ipAddress,
        country: a.country,
        clickedAt: a.clickedAt,
      })),
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('❌ [getUrlAnalytics] Database error:', {
      message: error.message,
      userId,
      id,
    });
    res.status(500).json({
      error: 'Failed to fetch analytics',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = {
  createUrl,
  getUserUrls,
  getUrlById,
  updateUrl,
  deleteUrl,
  redirectUrl,
  getUrlAnalytics,
};
