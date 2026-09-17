<?php

declare(strict_types=1);

/**
 * TYPO3 Additional Configuration for FrankenPHP & Valkey Environment
 *
 * This file is automatically loaded by TYPO3 to apply environment-specific settings.
 */

// -----------------------------------------------------------------------------
// 1. Reverse Proxy & Trusted Hosts
// -----------------------------------------------------------------------------
// Tell TYPO3 to trust HTTPS / SSL forwarded by reverse proxy (e.g., Caddy, Traefik)
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxySSL'] = '*';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyIP'] = '*';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyHeaderMultiValue'] = 'first';

// Dynamic Trusted Hosts regex pattern from environment or fallback
$trustedHostsPattern = getenv('TRUSTED_HOSTS_PATTERN') ?: '(localhost|127\.0\.0\.1|.*)';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['trustedHostsPattern'] = $trustedHostsPattern;

// -----------------------------------------------------------------------------
// 2. File & Folder Permissions
// -----------------------------------------------------------------------------
$GLOBALS['TYPO3_CONF_VARS']['SYS']['fileCreateMask'] = getenv('TYPO3_FILE_CREATE_MASK') ?: '0660';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['folderCreateMask'] = getenv('TYPO3_FOLDER_CREATE_MASK') ?: '2770';

// -----------------------------------------------------------------------------
// 3. Valkey / Redis Caching Backend
// -----------------------------------------------------------------------------
$redisHost = getenv('REDIS_HOST') ?: 'valkey';
$redisPort = (int)(getenv('REDIS_PORT') ?: 6379);
$redisPassword = getenv('REDIS_PASSWORD') ?: null;

if (!empty($redisHost)) {
    $cacheConfigurations = [
        'pages' => 0,
        'pagesection' => 1,
        'hash' => 2,
        'rootline' => 3,
    ];

    foreach ($cacheConfigurations as $cacheName => $dbIndex) {
        $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['backend'] =
            \TYPO3\CMS\Core\Cache\Backend\RedisBackend::class;
        $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['options'] = [
            'hostname' => $redisHost,
            'port' => $redisPort,
            'password' => $redisPassword,
            'database' => $dbIndex,
        ];
    }
}
