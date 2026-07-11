# ntfy-alertmanager config TEMPLATE (scfg). The ntfy-bridge-config service
# renders it at `up`, substituting __NTFY_ALERTS_TOPIC__ from the stack env
# (.env <- .env.sops). Topic names are secrets — never hardcode one here.
http-address :8080
log-level info
alert-mode single

cache {
    type memory
    duration 24h
    cleanup-interval 1h
}

ntfy {
    server https://ntfy.sh
    topic __NTFY_ALERTS_TOPIC__
}

resolved {
    tags "white_check_mark"
    priority 3
}

labels {
    order "severity"

    label "severity=critical" {
        priority 5
        tags "rotating_light"
    }

    label "severity=warning" {
        priority 4
        tags "warning"
    }
}
