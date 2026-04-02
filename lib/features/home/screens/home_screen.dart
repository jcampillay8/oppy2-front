// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
// Asumiremos que tienes una clase de colores definidos. Si no, usa los valores hexadecimales comentados.
// import 'package:oppy2_frontend/core/theme/app_theme.dart'; 

// --- DEFINICIÓN DE COLORES TEMPORALES (Si no usas AppColors) ---
class OppyColors {
  static const Color background = Color(0xFF0F172A); // Fondo muy oscuro
  static const Color cardGrey = Color(0xFF1E293B);   // Fondo de tarjetas secundarias
  static const Color primaryBlue = Color(0xFF3B82F6); // Azul brillante
  static const Color accentYellow = Color(0xFFFBBF24); // Amarillo/Oro
  static const Color textGrey = Color(0xFF94A3B8);   // Texto secundario
  static const Color outlineGrey = Color(0xFF334155); // Bordes y líneas
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice para el menú inferior
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider para obtener datos reales del usuario
    final auth = context.watch<AuthProvider>();
    final String username = auth.user?.username ?? "Usuario";

    return Scaffold(
      backgroundColor: OppyColors.background,
      // Usamos SafeArea para evitar la barra de estado del teléfono
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. --- HEADER: Saludo, Energía y Racha ---
              _buildHeader(context, username),
              const SizedBox(height: 24),

              // 2. --- SECCIÓN: Mis Beneficios (Tarjeta Oro) ---
              _buildBenefitsSection(),
              const SizedBox(height: 32),

              // 3. --- SECCIÓN: Práctica Personalizada (2 tarjetas principales) ---
              _buildPracticeSection(),
              const SizedBox(height: 32),

              // 4. --- SECCIÓN: Habla con Amigos ---
              _buildFriendsSection(),
              const SizedBox(height: 32),

              // 5. --- SECCIÓN: Grupos Destacados ---
              _buildFeaturedGroupsSection(),
              const SizedBox(height: 32),

              // 6. --- SECCIÓN: Eventos Cercanos ---
              _buildNearbyEventsSection(),
              const SizedBox(height: 100), // Espacio extra para no chocar con el menú inferior
            ],
          ),
        ),
      ),
      
      // 7. --- MENÚ INFERIOR (Visualmente implementado) ---
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ===========================================================================
  // WIDGETS DE CONSTRUCCIÓN (COMPONENTES)
  // ===========================================================================

  // 1. --- Header ---
  Widget _buildHeader(BuildContext context, String username) {
    return Row(
      children: [
        // Avatar circular
        const CircleAvatar(
          radius: 24,
          backgroundColor: OppyColors.cardGrey,
          backgroundImage: AssetImage('assets/images/default_avatar.png'), // Asegúrate de tener esta imagen o usa NetworkImage
          child: Icon(Icons.person, color: OppyColors.textGrey), // Fallback si no hay imagen
        ),
        const SizedBox(width: 12),
        // Saludo y Nombre
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola de nuevo,',
              style: TextStyle(color: OppyColors.textGrey, fontSize: 14),
            ),
            Text(
              username,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Spacer(),
        // Contadores (Energía y Racha)
        _buildCounterTag(Icons.bolt, '198', OppyColors.accentYellow),
        const SizedBox(width: 8),
        _buildCounterTag(Icons.local_fire_department, '12', Colors.orange),
      ],
    );
  }

  // Pequeña etiqueta para energía/fuego
  Widget _buildCounterTag(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: OppyColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // 2. --- Sección de Beneficios (Tarjeta Azul) ---
  Widget _buildBenefitsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mis Beneficios', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Ver todo', style: TextStyle(color: OppyColors.primaryBlue))),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Degradado azul
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: OppyColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NIVEL ACTUAL', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Icon(Icons.verified, color: OppyColors.accentYellow, size: 20),
                          SizedBox(width: 6),
                          Text('Oro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  // Icono de regalo
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.redeem, color: Colors.white, size: 28),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Barra de progreso y textos
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1,250 Puntos', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text('Próximo: 1,500', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: 1250 / 1500,
                  minHeight: 8,
                  backgroundColor: Color(0xFF1E40AF), // Azul oscuro de fondo
                  valueColor: AlwaysStoppedAnimation<Color>(OppyColors.accentYellow),
                ),
              ),
              const SizedBox(height: 12),
              const Text('¡Estás cerca! Desbloquea un 20% en Starbucks.', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // 3. --- Sección de Práctica Personalizada (Roleplay e IA) ---
  Widget _buildPracticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Práctica Personalizada', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMainPracticeCard(
                icon: Icons.smart_toy_outlined, // Icono de robot
                iconColor: const Color(0xFFA78BFA), // Morado suave
                title: 'Roleplay IA',
                subtitle: 'Simula situaciones en restaurantes o viajes.',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMainPracticeCard(
                icon: Icons.mic_none_outlined,
                iconColor: const Color(0xFF34D399), // Verde esmeralda suave
                title: 'Coach de Voz',
                subtitle: 'Mejora tu acento y pronunciación.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tarjeta principal de práctica (Roleplay / Coach)
  Widget _buildMainPracticeCard({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: OppyColors.cardGrey, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const Icon(Icons.arrow_forward_ios, color: OppyColors.textGrey, size: 16),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: OppyColors.textGrey, fontSize: 13)),
        ],
      ),
    );
  }

  // 4. --- Sección Habla con Amigos ---
Widget _buildFriendsSection() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Habla con Amigos', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Color(0xFF34D399)),
                SizedBox(width: 6),
                Text('5 ONLINE', 
                  style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90, // Subimos un poco el alto para evitar desbordamientos de texto
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddFriendButton(),
              const SizedBox(width: 16),
              _buildFriendAvatar('Sarah', 'assets/images/friend1.png', online: true),
              const SizedBox(width: 16),
              _buildFriendAvatar('Mike', 'assets/images/friend2.png', online: true),
              const SizedBox(width: 16),
              _buildFriendAvatar('Elena', 'assets/images/friend3.png', online: false),
              const SizedBox(width: 16),
              _buildFriendAvatar('David', 'assets/images/friend4.png', online: false),
            ],
          ),
        )
      ],
    );
  }

// Botón "Invitar" amigo
  Widget _buildAddFriendButton() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: OppyColors.outlineGrey, 
              width: 2,
            ),
          ), // <--- ESTE PARÉNTESIS CIERRA EL BoxDecoration
          child: const Icon(Icons.person_add_alt_1, color: OppyColors.textGrey),
        ),
        const SizedBox(height: 6),
        const Text(
          'Invitar', 
          style: TextStyle(color: OppyColors.textGrey, fontSize: 12),
        ),
      ],
    );
  }

  // Avatar de amigo individual con punto de status
  Widget _buildFriendAvatar(String name, String imagePath, {required bool online}) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: OppyColors.cardGrey,
              // backgroundImage: AssetImage(imagePath), // Descomenta si tienes las imágenes
              child: Text(name[0], style: const TextStyle(color: OppyColors.textGrey, fontSize: 20)), // Fallback: inicial
            ),
            if (online)
              const Positioned(
                bottom: 0, right: 0,
                child: CircleAvatar(radius: 7, backgroundColor: OppyColors.background, child: CircleAvatar(radius: 5, backgroundColor: Color(0xFF34D399))),
              )
          ],
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // 5. --- Sección Grupos Destacados ---
  Widget _buildFeaturedGroupsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grupos Destacados', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Explorar', style: TextStyle(color: OppyColors.primaryBlue))),
          ],
        ),
        const SizedBox(height: 12),
        _buildGroupCard(
          icon: Icons.business_center,
          title: 'English for Business',
          members: '12/20',
          level: 'INTERMEDIO',
        ),
        const SizedBox(height: 12),
        _buildGroupCard(
          icon: Icons.flight_takeoff,
          title: 'Travel & Culture',
          members: '8/15',
          level: 'TODOS',
        ),
      ],
    );
  }

  // Tarjeta de grupo individual
  Widget _buildGroupCard({required IconData icon, required String title, required String members, required String level}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: OppyColors.cardGrey, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: OppyColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: OppyColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_outline, color: OppyColors.textGrey, size: 14),
                    const SizedBox(width: 4),
                    Text(members, style: const TextStyle(color: OppyColors.textGrey, fontSize: 13)),
                    const SizedBox(width: 12),
                    Text(level, style: TextStyle(color: OppyColors.primaryBlue.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: OppyColors.textGrey, size: 16),
        ],
      ),
    );
  }

// 6. --- Sección Eventos Cercanos ---
  Widget _buildNearbyEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eventos cercanos', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: OppyColors.cardGrey, 
            borderRadius: BorderRadius.circular(20)
          ),
          clipBehavior: Clip.hardEdge, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del evento con degradado
              Container(
                height: 140, 
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12, 
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text(
                          'HOY, 19:00', 
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Intercambio de Idiomas en La Roma', 
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: OppyColors.textGrey, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Café Pendulo, Ciudad de México', 
                          style: TextStyle(color: OppyColors.textGrey, fontSize: 13)
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Fila de asistentes y botón (Corregido)
                    Row(
                      children: [
                        // Stack de avatares para evitar el ancho negativo
                        SizedBox(
                          width: 45, // Espacio suficiente para los dos círculos solapados
                          height: 24,
                          child: Stack(
                            children: [
                              const CircleAvatar(
                                radius: 12, 
                                backgroundColor: OppyColors.primaryBlue
                              ),
                              Positioned(
                                left: 14, // Esto logra el efecto visual sin error
                                child: Container(
                                  padding: const EdgeInsets.all(2), // Borde de separación
                                  decoration: const BoxDecoration(
                                    color: OppyColors.cardGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 10, 
                                    backgroundColor: Color(0xFF34D399)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+12', 
                          style: TextStyle(color: OppyColors.textGrey, fontSize: 12)
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OppyColors.primaryBlue.withOpacity(0.1),
                            foregroundColor: OppyColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ASISTIR'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. --- Menú Inferior (BottomNavigationBar) ---
  // Nota: Dejé los labels en español para que coincidan exactamente con la imagen,
  // pero recuerda que tu app usa internacionalización.
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: OppyColors.outlineGrey, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: OppyColors.background,
        type: BottomNavigationBarType.fixed, // Necesario para más de 3 items
        selectedItemColor: OppyColors.primaryBlue,
        unselectedItemColor: OppyColors.textGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Lecciones'),
          BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: 'Rank'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}