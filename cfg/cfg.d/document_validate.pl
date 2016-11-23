######################################################################
#
# validate_document( $document, $repository, $for_archive ) 
#
######################################################################
# $document 
# - Document object
# $repository 
# - Repository object (the current repository)
# $for_archive
# - boolean (see comments at the start of the validation section)
#
# returns: @problems
# - ARRAY of DOM objects (may be null)
#
######################################################################
# Validate a document. validate_document_meta will be called auto-
# matically, so you don't need to duplicate any checks.
#
######################################################################


$c->{validate_document} = sub
{
	my( $document, $repository, $for_archive ) = @_;

	my @problems = ();

	my $xml = $repository->xml();

	# CHECKS IN HERE

	# "other" documents must have a description set
	if( $document->value( "format" ) eq "other" &&
	   !EPrints::Utils::is_set( $document->value( "formatdesc" ) ) )
	{
		my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
		push @problems, $repository->html_phrase( 
					"validate:need_description" ,
					type=>$document->render_citation("brief"),
					fieldname=>$fieldname );
	}

	# security can't be "public" if date embargo set
	if( $document->value( "security" ) eq "public" &&
		EPrints::Utils::is_set( $document->value( "date_embargo" ) ) )
	{
		my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
		push @problems, $repository->html_phrase( 
					"validate:embargo_check_security" ,
					fieldname=>$fieldname );
	}

	# embargo expiry date must be in the future
	if( EPrints::Utils::is_set( $document->value( "date_embargo" ) ) )
	{
		my $value = $document->value( "date_embargo" );
		my ($thisyear, $thismonth, $thisday) = EPrints::Time::get_date_array();
		my ($year, $month, $day) = split( '-', $value );
		if( $year < $thisyear || ( $year == $thisyear && $month < $thismonth ) ||
			( $year == $thisyear && $month == $thismonth && $day <= $thisday ) )
		{
			my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
			push @problems,
				$repository->html_phrase( "validate:embargo_invalid_date",
				fieldname=>$fieldname );
		}
	}

         # inizio test antivirus: dovrebbe essere l'ultimo test dato che se trova un virus
         #        elimina questo documento (anche se ha piu' file)
         my %files=$document->files;
         my $local_path=$document->local_path;
         foreach my $file (keys %files) {
	   my $upload=$repository->get_conf('upload','upload_limit');
           if ($upload) {
	     my $size=-s "$local_path/$file";
	     if ($size > $upload ) {
	       $document->remove;
	       $repository->log( $repository->phrase("document_validate:upload_error_maxsize",file=>$repository->make_text("$local_path/$file"),size=>$repository->make_text($size),limit=>$repository->make_text($upload)));
	       push @problems,$repository->html_phrase("document_validate:upload_error_maxsize",file=>$repository->make_text("$file"),size=>$repository->make_text($size),limit=>$repository->make_text($upload));
	       last;
	     }
	   }
	   if ( -x "/usr/bin/clamdscan") {
             my $virus=`/usr/bin/clamdscan --no-summary --fdpass $local_path/$file 2>/dev/null`;
             if ($virus=~/FOUND/) {
               $virus=~s/^.*:\s*//;
               $virus=~s/\sFOUND\s*.*$//;
               $document->remove;
               $repository->log( $repository->phrase("document_validate:upload_error_virus",virus=>$repository->make_text($virus),file=>$repository->make_text("$local_path/$file")));
               push @problems, $repository->html_phrase("document_validate:upload_error_virus",virus=>$repository->make_text($virus),file=>$repository->make_text($file));
               last;
              }
	    }
         }
         # fine test antivirus



	return( @problems );
};
