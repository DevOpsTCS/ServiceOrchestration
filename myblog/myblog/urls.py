from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    url(r'^$', 'myblog.views.home', name='home'),

    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
    url(r'^post/form_upload.html$','myblog.views.post_form_upload', name='post_form_upload'),
    url(r'^post_form_upload.html$','myblog.views.post_form_upload', name='post_form_upload'),
    url(r'^process_form_data$','myblog.views.process_form_data'),
    # Map the view function myblog.views.post_detail() to an URL pattern
    #url(r'^post/(?P<post_id>\d+)/detail.html$', 'myblog.views.post_detail', name='post_detail'),
)
