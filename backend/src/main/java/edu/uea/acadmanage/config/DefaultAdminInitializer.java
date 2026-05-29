package edu.uea.acadmanage.config;

import edu.uea.acadmanage.model.Pessoa;
import edu.uea.acadmanage.model.Role;
import edu.uea.acadmanage.model.Usuario;
import edu.uea.acadmanage.repository.PessoaRepository;
import edu.uea.acadmanage.repository.RoleRepository;
import edu.uea.acadmanage.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(prefix = "app.seed.admin", name = "enabled", havingValue = "true", matchIfMissing = true)
public class DefaultAdminInitializer implements ApplicationRunner {

    private static final Logger logger = LoggerFactory.getLogger(DefaultAdminInitializer.class);
    private static final String ADMIN_ROLE = "ROLE_ADMINISTRADOR";

    private final UsuarioRepository usuarioRepository;
    private final PessoaRepository pessoaRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final String adminEmail;
    private final String adminPassword;
    private final String adminName;
    private final String adminCpf;
    private final boolean resetPassword;

    public DefaultAdminInitializer(
            UsuarioRepository usuarioRepository,
            PessoaRepository pessoaRepository,
            RoleRepository roleRepository,
            PasswordEncoder passwordEncoder,
            @Value("${app.seed.admin.email:admin@uea.edu.br}") String adminEmail,
            @Value("${app.seed.admin.password:admin123}") String adminPassword,
            @Value("${app.seed.admin.name:Administrador do Sistema}") String adminName,
            @Value("${app.seed.admin.cpf:31452012040}") String adminCpf,
            @Value("${app.seed.admin.reset-password:true}") boolean resetPassword) {
        this.usuarioRepository = usuarioRepository;
        this.pessoaRepository = pessoaRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
        this.adminName = adminName;
        this.adminCpf = adminCpf;
        this.resetPassword = resetPassword;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        Role adminRole = roleRepository.findByNome(ADMIN_ROLE)
                .orElseGet(() -> {
                    Role role = new Role();
                    role.setNome(ADMIN_ROLE);
                    return roleRepository.save(role);
                });

        Pessoa pessoa = pessoaRepository.findByCpf(adminCpf)
                .orElseGet(Pessoa::new);
        pessoa.setNome(adminName);
        pessoa.setCpf(adminCpf);
        pessoa = pessoaRepository.save(pessoa);

        Usuario usuario = usuarioRepository.findByEmail(adminEmail)
                .orElseGet(Usuario::new);
        usuario.setEmail(adminEmail);
        usuario.setPessoa(pessoa);

        if (usuario.getId() == null || resetPassword) {
            usuario.setSenha(passwordEncoder.encode(adminPassword));
        }

        usuario.getRoles().add(adminRole);
        usuarioRepository.save(usuario);

        logger.info("Usuario administrador padrao garantido: {}", adminEmail);
    }
}
