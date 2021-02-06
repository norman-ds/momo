# dig data in opendata json file

# return value is a list of lists
jwrapper <- function(jfile) {
  res <- jsonlite::fromJSON(jfile)
  stopifnot(res$success)
  
  out <- res$result
  
  # function for reducing list
  `%redlist%` = function(e1,e2) 
    eval.parent(substitute(e1 <- e1[names(e1) %in% e2]))
  
  # selected list
  out %redlist% 
    c(
      'maintainer',
      'issued',
      'maintainer_email',
      'contact_points',
      'temporals',
      'id',
      'metadata_created',
      'display_name',
      'metadata_modified',
      'author',
      'author_email',
      'relations',
      'state',
      'spatial',
      'resources',# big list
      'groups', # big list
      'creator_user_id',
      'organization',# big list
      'name',
      'url',
      'revision_id',
      'identifier'
    )
  
  # selected resources list
  out$resources %redlist% 
    c(
      'issued',
      'modified',
      'package_id',
      'id',
      'size',
      'display_name',
      'title',
      'download_url',
      'state',
      'media_type',
      'hash',
      'description',
      'format',
      'mimetype',
      'name',
      'language',
      'rights',
      'url',
      'created',
      'revision_id',
      'identifier'
    )
  
  
  # selected organizazion list
  out$organization %redlist% c('display_name', 'id')
  
  return(out)
}

