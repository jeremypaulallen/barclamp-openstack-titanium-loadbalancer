name "haproxy"
description "Haproxy load-Balancer"
run_list(
        "recipe[haproxy::ip_nonlocal_bind]",
        "recipe[haproxy::install]",
        "recipe[haproxy::monitor]"
)
default_attributes()
override_attributes()
