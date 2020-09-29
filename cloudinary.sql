create type lib_cloudinary.upload_parameters as (
    generated_timestamp       text,
    api_key                   text,
    resource_type             text,
    endpoint                  text,
    public_id                 text,
    destination_folder        text,
    transformations           text,
    signature                 text,
    mode                      text
);

create or replace function lib_cloudinary._urlsafe_encode64(bin$ bytea) returns text as
$$
declare
    key$ text;
begin
    key$ = encode(bin$, 'base64');

    -- Base64 encoding contains 2 URL unsafe characters by default.
    -- The URL-safe version has these replacements.
    key$ = replace(key$, '/', '_'); -- url safe replacement
    key$ = replace(key$, '+', '-'); -- url safe replacement

    return key$;
end;
$$ security definer language plpgsql;
comment on function lib_cloudinary._urlsafe_encode64(bytea) is 'Returns the Base64-encoded version of bin. This method complies with “Base 64 Encoding with URL and Filename Safe Alphabet” in RFC 4648. The alphabet uses ‘-’ instead of ‘+’ and ‘_’ instead of ‘/’. Note that the result can still contain ‘=’.';


create or replace function lib_cloudinary._generate_upload_signature(upload_parameters$ lib_cloudinary.upload_parameters, api_secret$ text) returns text as
$$
declare
    to_sign$    text[];
begin
    if upload_parameters$.destination_folder is not null then
      to_sign$ = array_append(to_sign$, 'folder=' || upload_parameters$.destination_folder);
    end if;

    if upload_parameters$.public_id is not null then
      to_sign$ = array_append(to_sign$, 'public_id=' || upload_parameters$.public_id);
    end if;

    if upload_parameters$.generated_timestamp is not null then
      to_sign$ = array_append(to_sign$, 'timestamp=' || upload_parameters$.generated_timestamp);
    end if;

    if upload_parameters$.transformations is not null then
      to_sign$ = array_append(to_sign$, 'transformation=' || upload_parameters$.transformations);
    end if;

    if upload_parameters$.mode is not null then
      to_sign$ = array_append(to_sign$, 'type=' || upload_parameters$.mode);
    end if;

    return encode(public.digest(array_to_string(to_sign$, '&') || api_secret$, 'sha1'), 'hex');
end;
$$ security definer language plpgsql;
comment on function lib_cloudinary._generate_upload_signature(lib_cloudinary.upload_parameters, text) is 'Returns signature needed to upload (POST) an asset to cloudinary.';


create or replace function lib_cloudinary.get_asset_url(public_id$ text,
                                                        cloud_name$ text,
                                                        api_secret$ text,
                                                        mode$ text default 'authenticated',
                                                        resource_type$ text default 'image',
                                                        transformations$ text default '',
                                                        api_endpoint$ text default 'https://res.cloudinary.com/') returns text as
$$
declare
    signature$ text;
    toSign$ text;
begin
    assert left(public_id$, 1) <> '/'::text, 'public_id$ must not start with "/" character';

    assert left(transformations$, 1) <> '/'::text, 'transformations$ must not start with "/" character';
    assert right(transformations$, 1) <> '/'::text, 'transformations$ must not end with "/" character';

    assert right(api_endpoint$, 1) = '/'::text, 'api_endpoint$ must end with "/" character';

    -- concat_ws doesn't concat null parameters
    toSign$ = concat_ws('/', nullif(trim(transformations$), ''), public_id$);

    if api_secret$ is not null then
        -- compute signature
        signature$ = 's--' ||
                     substring(lib_cloudinary._urlsafe_encode64(
                                       public.digest(toSign$ || api_secret$, 'sha1')), 1, 8) ||
                     '--';
    else
        signature$ = '';
    end if;

    return api_endpoint$ || array_to_string(array [cloud_name$, resource_type$, mode$, signature$, toSign$], '/');
end ;
$$ security definer language plpgsql;
comment on function lib_cloudinary.get_asset_url(text, text, text, text, text, text, text) is 'Generate the complete URL along with its signature to download an asset';

create or replace function lib_cloudinary.get_upload_parameters(cloud_name$ text,
                                                                api_key$ text,
                                                                api_secret$ text,
                                                                transformations$ text default null,
                                                                timestamp$ timestamptz default now(),
                                                                public_id$ text default null,
                                                                folder$ text default null,
                                                                mode$ text default 'authenticated',
                                                                resource_type$ text default 'image',
                                                                api_endpoint$ text default 'https://api.cloudinary.com/v1.1/') returns lib_cloudinary.upload_parameters as
$$
declare
    upload_parameters$  lib_cloudinary.upload_parameters;
    endpoint$           text;
begin
    endpoint$ = api_endpoint$ || cloud_name$ || '/' || resource_type$ || '/' || 'upload';

    upload_parameters$.generated_timestamp = extract(epoch from timestamp$);
    upload_parameters$.api_key = api_key$;
    upload_parameters$.resource_type = resource_type$;
    upload_parameters$.endpoint = endpoint$;
    upload_parameters$.public_id = public_id$;
    upload_parameters$.destination_folder = folder$;
    upload_parameters$.transformations = transformations$;
    upload_parameters$.mode = mode$;
    upload_parameters$.signature = lib_cloudinary._generate_upload_signature(upload_parameters$, api_secret$);

    return upload_parameters$;
end ;
$$ security definer language plpgsql;

comment on function lib_cloudinary.get_upload_parameters(text, text, text, text, timestamptz, text, text, text, text, text) is 'Yield the parameters along with their signature to upload an asset';
