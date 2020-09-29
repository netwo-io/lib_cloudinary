-- lib_cloudinary tests.

---------------------------------- GENERATES DOWNLOAD URLS --------------------------------

create or replace function lib_test.test_case_lib_cloudinary_get_asset_url() returns void as $$
declare
  url$ text;
begin
  url$ = lib_cloudinary.get_asset_url(
    public_id$ := 'oljggoo15ng5h7rwrelj.jpg',
    cloud_name$ := 'dldh3zq4g',
    api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk'
  );

  perform lib_test.assert_equal(url$, 'https://res.cloudinary.com/dldh3zq4g/image/authenticated/s--M62dCPkD--/oljggoo15ng5h7rwrelj.jpg'::text);
end;
$$ language plpgsql;

create or replace function lib_test.test_case_lib_cloudinary_get_asset_url_with_folder() returns void as $$
declare
  url$ text;
begin
  url$ = lib_cloudinary.get_asset_url(
    public_id$ := 'actor-id-546/images/oljggoo15ng5h7rwrelj.jpg',
    cloud_name$ := 'dldh3zq4g',
    api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk'
  );

  perform lib_test.assert_equal(url$, 'https://res.cloudinary.com/dldh3zq4g/image/authenticated/s--Qtp64SYe--/actor-id-546/images/oljggoo15ng5h7rwrelj.jpg'::text);
end;
$$ language plpgsql;


create or replace function lib_test.test_case_lib_cloudinary_get_asset_url_for_pdf() returns void as $$
declare
  url$ text;
begin
  url$ = lib_cloudinary.get_asset_url(
    public_id$ := 'my-contract.pdf',
    cloud_name$ := 'dldh3zq4g',
    api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk',
    resource_type$ := 'raw'
  );

  perform lib_test.assert_equal(url$, 'https://res.cloudinary.com/dldh3zq4g/raw/authenticated/s--CiN9OCr4--/my-contract.pdf'::text);
end;
$$ language plpgsql;


create or replace function lib_test.test_case_lib_cloudinary_get_asset_url_with_transformations() returns void as $$
declare
  url$ text;
begin
  url$ = lib_cloudinary.get_asset_url(
    public_id$ := 'oljggoo15ng5h7rwrelj.jpg',
    cloud_name$ := 'dldh3zq4g',
    api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk',
    transformations$ := 'h_200,w_200'
  );

  perform lib_test.assert_equal(url$, 'https://res.cloudinary.com/dldh3zq4g/image/authenticated/s--1XbZpwfL--/h_200,w_200/oljggoo15ng5h7rwrelj.jpg'::text);
end;
$$ language plpgsql;


---------------------------------- GENERATES UPLOAD URLS --------------------------------

create or replace function lib_test.test_case_lib_cloudinary_get_upload_parameters() returns void as $$
declare
  parameters$ lib_cloudinary.upload_parameters;
begin
  parameters$ = lib_cloudinary.get_upload_parameters(
    cloud_name$ := 'dldh3zq4g',
    api_key$ := '548615367811954',
    api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk',
    timestamp$ := '2020-09-30 15:45:00+02'
  );

  perform lib_test.assert_equal(parameters$.generated_timestamp, '1601473500');
  perform lib_test.assert_equal(parameters$.api_key, '548615367811954');
  perform lib_test.assert_equal(parameters$.resource_type, 'image');
  perform lib_test.assert_equal(parameters$.endpoint, 'https://api.cloudinary.com/v1.1/dldh3zq4g/image/upload');
  perform lib_test.assert_equal(parameters$.mode, 'authenticated');
  perform lib_test.assert_null(parameters$.public_id);
  perform lib_test.assert_null(parameters$.destination_folder);
  perform lib_test.assert_null(parameters$.transformations);
  perform lib_test.assert_equal(parameters$.signature, 'b398c90a2a1aeb66d5ae2c6e6c6fee64a022f502');
end;
$$ language plpgsql;


create or replace function lib_test.test_case_lib_cloudinary_get_upload_parameters_with_transformations() returns void as $$
declare
  parameters$ lib_cloudinary.upload_parameters;
begin
  parameters$ = lib_cloudinary.get_upload_parameters(
    cloud_name$ := 'dldh3zq4g',
    api_key$ := '548615367811954',
    api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk',
    transformations$ := 'w_200,h_200,c_limit',
    timestamp$ := '2020-09-30 15:45:00+02'
  );

  perform lib_test.assert_equal(parameters$.generated_timestamp, '1601473500');
  perform lib_test.assert_equal(parameters$.api_key, '548615367811954');
  perform lib_test.assert_equal(parameters$.resource_type, 'image');
  perform lib_test.assert_equal(parameters$.endpoint, 'https://api.cloudinary.com/v1.1/dldh3zq4g/image/upload');
  perform lib_test.assert_equal(parameters$.mode, 'authenticated');
  perform lib_test.assert_null(parameters$.public_id);
  perform lib_test.assert_null(parameters$.destination_folder);
  perform lib_test.assert_equal(parameters$.transformations, 'w_200,h_200,c_limit');
  perform lib_test.assert_equal(parameters$.signature, '0a8762606d3af936867f00ed7609d713ae0ea20d');
end;
$$ language plpgsql;


create or replace function lib_test.test_case_lib_cloudinary_get_upload_parameters_with_folder() returns void as
$$
declare
    parameters$ lib_cloudinary.upload_parameters;
begin
    parameters$ = lib_cloudinary.get_upload_parameters(
      cloud_name$ := 'dldh3zq4g',
      folder$ := 'tenant_13a65699-8722-4b2d-ad8a-c0a2dbb1e304/group_c4ee11ba-81c1-4cbf-abe3-18b9cd4b967b',
      resource_type$ := 'raw',
      api_key$ := '548615367811954',
      api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk',
      timestamp$ := '2020-09-30 15:45:00+02'
    );

    perform lib_test.assert_equal(parameters$.generated_timestamp, '1601473500');
    perform lib_test.assert_equal(parameters$.api_key, '548615367811954');
    perform lib_test.assert_equal(parameters$.resource_type, 'raw');
    perform lib_test.assert_equal(parameters$.endpoint, 'https://api.cloudinary.com/v1.1/dldh3zq4g/raw/upload');
    perform lib_test.assert_equal(parameters$.mode, 'authenticated');
    perform lib_test.assert_null(parameters$.public_id);
    perform lib_test.assert_equal(parameters$.destination_folder, 'tenant_13a65699-8722-4b2d-ad8a-c0a2dbb1e304/group_c4ee11ba-81c1-4cbf-abe3-18b9cd4b967b');
    perform lib_test.assert_null(parameters$.transformations);
    perform lib_test.assert_equal(parameters$.signature, '31ec032d8be276b733a1cd1be61a7cfb81024b95');
end;
$$ language plpgsql;


create or replace function lib_test.test_case_lib_cloudinary_get_upload_parameters_with_public_id() returns void as
$$
declare
    parameters$ lib_cloudinary.upload_parameters;
begin
    parameters$ = lib_cloudinary.get_upload_parameters(
      cloud_name$ := 'dldh3zq4g',
      resource_type$ := 'image',
      public_id$ := 'netwo.jpg',
      api_key$ := '548615367811954',
      api_secret$ := 't9n-FeagXcAnLPn21KubES5Lysk',
      timestamp$ := '2020-09-30 15:45:00+02'
    );

    perform lib_test.assert_equal(parameters$.generated_timestamp, '1601473500');
    perform lib_test.assert_equal(parameters$.api_key, '548615367811954');
    perform lib_test.assert_equal(parameters$.resource_type, 'image');
    perform lib_test.assert_equal(parameters$.endpoint, 'https://api.cloudinary.com/v1.1/dldh3zq4g/image/upload');
    perform lib_test.assert_equal(parameters$.mode, 'authenticated');
    perform lib_test.assert_equal(parameters$.public_id, 'netwo.jpg');
    perform lib_test.assert_null(parameters$.destination_folder);
    perform lib_test.assert_null(parameters$.transformations);
    perform lib_test.assert_equal(parameters$.signature, '5e4e7564070fac222c8e61009af1830d25de8593');
end;
$$ language plpgsql;
