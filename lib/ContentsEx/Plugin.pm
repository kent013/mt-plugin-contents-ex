package ContentsEx::Plugin;

use strict;
use warnings;
use utf8;

sub _hdlr_contents_ex {
    my ($ctx, $args, $cond) = @_;

    # Check if we should include unpublished content
    my $include_unpublished = $args->{include_unpublished} || 0;

    # If include_unpublished is false (default), just call the original handler
    if (!$include_unpublished) {
        require MT::Template::Tags::ContentType;
        return MT::Template::Tags::ContentType::_hdlr_contents($ctx, $args, $cond);
    }

    # If include_unpublished is true, we need to modify the behavior
    # We'll create a custom version that doesn't filter by status

    # This is a simplified version of _hdlr_contents that removes the status filter
    # Most of the code is copied from the original handler

    my $at = $ctx->{current_archive_type} || $ctx->{archive_type};
    my $archiver = MT->publisher->archiver($at) if $at;
    my $blog_id = $args->{site_id} || $args->{blog_id} || $ctx->stash('blog_id');
    my $blog = $ctx->stash('blog');

    return $ctx->_no_site_error unless $blog_id;

    my (@filters, %terms, %args, %blog_terms, %blog_args);
    %terms = %blog_terms = (blog_id => $blog_id);

    # Get content type
    require MT::Template::Tags::ContentType;
    my $content_type = MT::Template::Tags::ContentType::_get_content_type($ctx, $args, \%blog_terms)
        or return;
    my $content_type_id = scalar(@$content_type) == 1
        ? $content_type->[0]->id
        : [map { $_->id } @$content_type];

    $terms{content_type_id} = $content_type_id;

    # IMPORTANT: We don't set the status filter when include_unpublished is true
    # This is the key difference from the original handler
    # Original line: $terms{status} = MT::ContentStatus::RELEASE();

    # Set default sort
    unless (exists $args{sort}) {
        $args{sort} = 'authored_on';
        $args{direction} = $args->{sort_order} || 'descend';
    }

    # Handle limit and offset
    delete $args->{limit} if exists $args->{limit} && $args->{limit} eq 'none';
    $args{offset} = $args->{offset} if $args->{offset};

    # Load contents
    require MT::ContentData;
    my @contents = MT::ContentData->load(\%terms, \%args);

    # Build the output
    my $res = '';
    my $tok = $ctx->stash('tokens');
    my $builder = $ctx->stash('builder');
    my $i = 0;
    my $vars = $ctx->{__stash}{vars} ||= {};

    local $ctx->{__stash}{contents} = (@contents && defined $contents[0]) ? \@contents : undef;

    for my $content_data (@contents) {
        local $vars->{__first__} = !$i;
        local $vars->{__last__} = !defined $contents[$i + 1];
        local $vars->{__odd__} = ($i % 2) == 0;
        local $vars->{__even__} = ($i % 2) == 1;
        local $vars->{__counter__} = $i + 1;
        local $ctx->{__stash}{blog} = $content_data->blog;
        local $ctx->{__stash}{blog_id} = $content_data->blog_id;
        local $ctx->{__stash}{content} = $content_data;

        my $ct_id = $content_data->content_type_id;
        my $content_type = MT::ContentType->load($ct_id);
        local $ctx->{__stash}{content_type} = $content_type;

        defined(my $out = $builder->build($ctx, $tok, {
            %{$cond},
            ContentsHeader => !$i,
            ContentsFooter => !defined $contents[$i + 1],
        })) or return $ctx->error($builder->errstr);

        $res .= $out;
        $i++;
    }

    if (!@contents) {
        return MT::Template::Context::_hdlr_pass_tokens_else(@_);
    }

    $res;
}

1;
