from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'myproject.views.index', name='home'),
    url(r'^click/$', 'myproject.views.click', name='home'),
    url(r'^devops-build-', 'myproject.views.run', name='home'),
    url(r'^admin/', include(admin.site.urls)),
)
